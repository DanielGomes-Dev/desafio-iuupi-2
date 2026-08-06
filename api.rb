# frozen_string_literal: true

require "sinatra"
require "bigdecimal"
require "json"
require "time"

set :bind, "0.0.0.0"
set :port, 3001
set :server, :puma
set :show_exceptions, false

TOKEN = "desafio-mobile-token"
TRANSACTION_TYPES = %w[credit debit].freeze
DEFAULT_PAGE = 1
DEFAULT_PER_PAGE = 10
MAX_PER_PAGE = 50
SLOW_RESPONSE_SECONDS = 5
OPENAPI_PATH = File.expand_path("openapi.yaml", __dir__)
INITIAL_BALANCE_CENTS = 5_840
DEBIT_DESCRIPTIONS = [
  "Lanche",
  "Refrigerante",
  "Material escolar",
  "Almoço"
].freeze
DEBIT_AMOUNTS_CENTS = [1_200, 850, 1_575, 2_250].freeze

USER = {
  id: 1,
  name: "João da Silva",
  cpf: "12345678900",
  school: "Escola Exemplo",
  registration: "20260001",
  avatar_url: "https://i.pravatar.cc/300?img=12"
}.freeze

TRANSACTIONS = Array.new(25) do |index|
  credit = (index % 5).zero?
  debit_index = index % DEBIT_DESCRIPTIONS.length
  amount_cents = credit ? 5_000 : DEBIT_AMOUNTS_CENTS[debit_index]

  {
    id: index + 1,
    type: credit ? "credit" : "debit",
    description: credit ? "Recarga de saldo" : DEBIT_DESCRIPTIONS[debit_index],
    amount: amount_cents / 100.0,
    created_at: (Time.now - index * 86_400).iso8601
  }
end

STATE_MUTEX = Mutex.new
WALLET_STATE = {
  balance_cents: INITIAL_BALANCE_CENTS,
  next_transaction_id: TRANSACTIONS.length + 1
}

before do
  content_type :json

  headers(
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Methods" => "GET, POST, PUT, PATCH, DELETE, OPTIONS",
    "Access-Control-Allow-Headers" => "Authorization, Content-Type"
  )
end

options "*" do
  status 204
  body ""
end

helpers do
  def json_body
    request.body.rewind
    body = request.body.read

    return {} if body.empty?

    JSON.parse(body, symbolize_names: true)
  rescue JSON::ParserError
    json_error!(
      400,
      error: "invalid_json",
      message: "O corpo da requisição não contém um JSON válido"
    )
  end

  def json_error!(status_code, error:, message:)
    halt status_code, {
      error: error,
      message: message
    }.to_json
  end

  def authenticate!
    authorization = request.env["HTTP_AUTHORIZATION"]

    return if authorization == "Bearer #{TOKEN}"

    json_error!(
      401,
      error: "unauthorized",
      message: "Token ausente ou inválido"
    )
  end

  def positive_integer_parameter!(name, default:, maximum: nil)
    value = params[name]
    return default if value.nil?

    number = Integer(value, 10)

    unless number.positive?
      json_error!(
        400,
        error: "invalid_parameter",
        message: "O parâmetro #{name} deve ser um número inteiro positivo"
      )
    end

    if maximum && number > maximum
      json_error!(
        400,
        error: "invalid_parameter",
        message: "O parâmetro #{name} deve ser menor ou igual a #{maximum}"
      )
    end

    number
  rescue ArgumentError, TypeError
    json_error!(
      400,
      error: "invalid_parameter",
      message: "O parâmetro #{name} deve ser um número inteiro positivo"
    )
  end

  def transaction_type_parameter!
    type = params["type"]
    return nil if type.nil?
    return type if TRANSACTION_TYPES.include?(type)

    json_error!(
      400,
      error: "invalid_parameter",
      message: "O parâmetro type deve ser credit ou debit"
    )
  end

  def money_from_cents(cents)
    (cents / 100.0).round(2)
  end

  def money_cents!(value, field:)
    unless value.is_a?(Numeric) && value.finite?
      json_error!(
        422,
        error: "validation_error",
        message: "O campo #{field} deve ser um valor monetário positivo"
      )
    end

    decimal = BigDecimal(value.to_s)
    cents = decimal * 100

    unless decimal.positive? && cents.frac.zero?
      json_error!(
        422,
        error: "validation_error",
        message: "O campo #{field} deve ser positivo e possuir no máximo duas casas decimais"
      )
    end

    cents.to_i
  rescue ArgumentError
    json_error!(
      422,
      error: "validation_error",
      message: "O campo #{field} deve ser um valor monetário positivo"
    )
  end

  def current_user
    STATE_MUTEX.synchronize do
      USER.merge(balance: money_from_cents(WALLET_STATE[:balance_cents]))
    end
  end
end

get "/" do
  {
    name: "Desafio Mobile API",
    status: "online",
    documentation: "/docs",
    openapi: "/openapi.yaml",
    endpoints: {
      login: "POST /login",
      profile: "GET /me",
      transactions: "GET /transactions",
      create_transaction: "POST /transactions",
      transaction: "GET /transactions/:id",
    }
  }.to_json
end

get "/docs" do
  content_type :html

  <<~HTML
    <!doctype html>
    <html lang="pt-BR">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Desafio Mobile API — Swagger UI</title>
        <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui.css">
      </head>
      <body>
        <div id="swagger-ui"></div>
        <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-bundle.js" crossorigin></script>
        <script>
          window.onload = () => {
            SwaggerUIBundle({
              url: "/openapi.yaml",
              dom_id: "#swagger-ui",
              deepLinking: true,
              persistAuthorization: true,
              validatorUrl: null
            });
          };
        </script>
      </body>
    </html>
  HTML
end

get "/openapi.yaml" do
  content_type "application/yaml"
  send_file OPENAPI_PATH
end

post "/login" do
  payload = json_body

  valid_cpf = payload[:cpf].to_s.gsub(/\D/, "") == USER[:cpf]
  valid_password = payload[:password] == "123456"

  unless valid_cpf && valid_password
    json_error!(
      401,
      error: "invalid_credentials",
      message: "CPF ou senha inválidos"
    )
  end

  {
    access_token: TOKEN,
    token_type: "Bearer",
    user: current_user
  }.to_json
end

get "/me" do
  authenticate!

  current_user.to_json
end

get "/transactions" do
  authenticate!

  page = positive_integer_parameter!("page", default: DEFAULT_PAGE)
  per_page = positive_integer_parameter!(
    "per_page",
    default: DEFAULT_PER_PAGE,
    maximum: MAX_PER_PAGE
  )
  type = transaction_type_parameter!
  transaction_snapshot = STATE_MUTEX.synchronize do
    TRANSACTIONS.map(&:dup)
  end

  transactions =
    if type
      transaction_snapshot.select { |transaction| transaction[:type] == type }
    else
      transaction_snapshot
    end

  offset = (page - 1) * per_page
  items = transactions.slice(offset, per_page) || []

  {
    data: items,
    pagination: {
      page: page,
      per_page: per_page,
      total: transactions.length,
      total_pages: (transactions.length.to_f / per_page).ceil
    }
  }.to_json
end

post "/transactions" do
  authenticate!

  payload = json_body
  type = payload[:type]

  unless TRANSACTION_TYPES.include?(type)
    json_error!(
      422,
      error: "validation_error",
      message: "O campo type deve ser credit ou debit"
    )
  end

  amount_cents = money_cents!(payload[:amount], field: "amount")
  description = payload[:description]
  description = type == "credit" ? "Recarga de saldo" : "Saque de saldo" if description.nil?

  unless description.is_a?(String) &&
      description.strip.length.between?(1, 100)
    json_error!(
      422,
      error: "validation_error",
      message: "O campo description deve possuir entre 1 e 100 caracteres"
    )
  end

  result = STATE_MUTEX.synchronize do
    current_balance = WALLET_STATE[:balance_cents]

    if type == "debit" && amount_cents > current_balance
      json_error!(
        422,
        error: "insufficient_balance",
        message: "Saldo insuficiente para realizar o saque"
      )
    end

    balance_cents =
      if type == "credit"
        current_balance + amount_cents
      else
        current_balance - amount_cents
      end

    transaction = {
      id: WALLET_STATE[:next_transaction_id],
      type: type,
      description: description.strip,
      amount: money_from_cents(amount_cents),
      created_at: Time.now.iso8601
    }

    WALLET_STATE[:balance_cents] = balance_cents
    WALLET_STATE[:next_transaction_id] += 1
    TRANSACTIONS.unshift(transaction)

    {
      transaction: transaction,
      balance: money_from_cents(balance_cents)
    }
  end

  status 201
  result.to_json
end

get "/transactions/:id" do
  authenticate!

  transaction = STATE_MUTEX.synchronize do
    TRANSACTIONS.find { |item| item[:id] == params[:id].to_i }&.dup
  end

  unless transaction
    json_error!(
      404,
      error: "not_found",
      message: "Transação não encontrada"
    )
  end

  transaction.to_json
end

get "/simulate/error" do
  json_error!(
    500,
    error: "internal_server_error",
    message: "Erro simulado pela API"
  )
end

get "/simulate/slow" do
  sleep SLOW_RESPONSE_SECONDS

  {
    message: "Resposta retornada após #{SLOW_RESPONSE_SECONDS} segundos",
    delay_seconds: SLOW_RESPONSE_SECONDS
  }.to_json
end

not_found do
  {
    error: "not_found",
    message: "Endpoint não encontrado"
  }.to_json
end

error do
  {
    error: "internal_server_error",
    message: "Ocorreu um erro inesperado"
  }.to_json
end
