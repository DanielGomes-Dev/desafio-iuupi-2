import 'package:carteira_digital_escolar/core/constants/app_url.dart';
import 'package:carteira_digital_escolar/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import '../../../../shared/models/transaction_model.dart';

/// Filtro aplicado na busca do extrato.
/// Mantém a regra de "como montar os query params" fora da tela.
class StatementFilter {
  final String? type; // 'credit' | 'debit' | null (todos)

  const StatementFilter({this.type});

  Map<String, dynamic>? toQueryParameters() {
    return type == null ? null : {'type': type};
  }
}

/// Repositório responsável por buscar as transações do extrato.
/// Isola Dio, endpoint, headers e parsing — a tela não sabe (nem precisa
/// saber) de nenhum desses detalhes.
class StatementRepository {
  final Dio _dio;

  StatementRepository({Dio? dio}): _dio = dio ??
        (Dio(
          BaseOptions(
            baseUrl:  Urls.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )..interceptors.add(AuthInterceptor()));

  /// Busca transações do extrato.
  /// GET /transactions
  ///
  /// Lança [DioException] ou [Exception] em caso de falha — quem chama
  /// decide o que fazer (ex.: cair para dados mockados).
  Future<List<TransactionModel>> getTransactions({
    StatementFilter filter = const StatementFilter(),
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transactions',
      queryParameters: filter.toQueryParameters(),
    );

    final data = response.data?['data'];
    if (data is! List) {
      throw Exception('Formato de resposta inesperado em /transactions');
    }

    return data
        .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}