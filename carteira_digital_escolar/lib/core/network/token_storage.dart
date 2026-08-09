/// Guarda o token de acesso em memória para toda a sessão do app.
/// Os repositórios (via [AuthInterceptor]) leem daqui — ninguém mais
/// precisa saber ou montar o header 'Authorization' manualmente.
class TokenStorage {
  TokenStorage._internal();
  static final TokenStorage instance = TokenStorage._internal();

  String? _token;
  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }
}