import 'package:carteira_digital_escolar/core/constants/app_url.dart';
import 'package:dio/dio.dart';
import '../model/user_model.dart';

class LoginResult {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  const LoginResult({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });
}

class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: Urls.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// POST /login
  Future<LoginResult> login({
    required String cpf,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {'cpf': cpf, 'password': password},
    );

    final data = response.data;
    final accessToken = data?['access_token'] as String?;
    final userJson = data?['user'] as Map<String, dynamic>?;

    if (accessToken == null || userJson == null) {
      throw Exception('Resposta de login em formato inesperado.');
    }

    return LoginResult(
      accessToken: accessToken,
      tokenType: data?['token_type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(userJson),
    );
  }
}