import 'package:carteira_digital_escolar/shared/models/transaction_model.dart';
import 'package:dio/dio.dart';

/// Resultado de uma operação de recarga/saque: a transação criada e o
/// novo saldo, exatamente como a API devolve em `POST /transactions`.
class WalletOperationResult {
  final TransactionModel transaction;
  final double balance;

  const WalletOperationResult({
    required this.transaction,
    required this.balance,
  });
}

/// Erro de negócio retornado pela API (formato `{ error, message }`).
/// `code` é o valor estável de `error` (ex.: `insufficient_balance`),
/// útil para decisões da UI; `message` já vem pronto para exibição.
class WalletApiException implements Exception {
  final String code;
  final String message;

  const WalletApiException({required this.code, required this.message});

  bool get isInsufficientBalance => code == 'insufficient_balance';

  @override
  String toString() => message;
}

/// Repositório responsável pelas operações de recarga e saque da carteira.
class WalletRepository {
  final Dio _dio;

  WalletRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'http://10.0.2.2:3001', // ← Altere se necessário
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  /// Cria uma recarga (crédito), aumentando o saldo.
  Future<WalletOperationResult> recharge({
    required double amount,
    String? description,
  }) {
    return _createTransaction(
      type: 'credit',
      amount: amount,
      description: description,
    );
  }

  /// Cria um saque (débito), reduzindo o saldo.
  /// Lança [WalletApiException] com `code == 'insufficient_balance'`
  /// quando o saldo é menor que o valor solicitado.
  Future<WalletOperationResult> withdraw({
    required double amount,
    String? description,
  }) {
    return _createTransaction(
      type: 'debit',
      amount: amount,
      description: description,
    );
  }

  /// POST /transactions
  Future<WalletOperationResult> _createTransaction({
    required String type,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/transactions',
        data: {
          'type': type,
          'amount': amount,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer desafio-mobile-token',
          },
        ),
      );

      final data = response.data!;
      final transaction = TransactionModel.fromJson(
        Map<String, dynamic>.from(data['transaction']),
      );
      final balance = (data['balance'] as num).toDouble();

      return WalletOperationResult(transaction: transaction, balance: balance);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  WalletApiException _mapError(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      return WalletApiException(
        code: responseData['error']?.toString() ?? 'unknown_error',
        message: responseData['message']?.toString() ??
            'Não foi possível concluir a operação.',
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const WalletApiException(
          code: 'timeout',
          message: 'Tempo limite excedido. Tente novamente.',
        );
      case DioExceptionType.connectionError:
        return const WalletApiException(
          code: 'offline',
          message: 'Sem conexão com a internet. Verifique e tente novamente.',
        );
      default:
        return const WalletApiException(
          code: 'unknown_error',
          message: 'Não foi possível concluir a operação. Tente novamente.',
        );
    }
  }
}