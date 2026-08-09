import 'package:carteira_digital_escolar/core/network/auth_interceptor.dart';
import 'package:carteira_digital_escolar/features/auth/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({Dio? dio})
      : _dio = dio ??
          (Dio(BaseOptions(
            baseUrl: 'http://10.0.2.2:3001',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ))..interceptors.add(AuthInterceptor()));

  Future<UserModel> getCurrentUser() async {
    try {
      debugPrint('🔄 Buscando usuário via GET /me...');

      final response = await _dio.get<Map<String, dynamic>>('/me');

      debugPrint('📍 Status: ${response.statusCode}');
      debugPrint('📦 Dados: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data!);
        debugPrint('✅ Usuário carregado com SUCESSO: ${user.name}');
        return user;
      }

      throw Exception('Resposta vazia ou status inválido: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ ERRO na requisição: ${e.message}');
      rethrow;
    }
  }
}