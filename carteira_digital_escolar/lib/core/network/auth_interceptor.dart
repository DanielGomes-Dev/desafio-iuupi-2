import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Injeta automaticamente o header Authorization em toda requisição,
/// usando o token salvo em [TokenStorage] no momento do login.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = TokenStorage.instance.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}