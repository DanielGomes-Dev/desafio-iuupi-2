import 'package:carteira_digital_escolar/features/auth/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({Dio? dio}) 
    : _dio = dio ?? Dio(BaseOptions(
        baseUrl: 'http://10.0.2.2:3001', // ← Altere se necessário
      ));

  /// Buscar dados do usuário logado
  /// GET /v1/user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer desafio-mobile-token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data!);
        debugPrint('✅ Usuário carregado: ${user.name}');
        return user;
      }

      throw Exception('Erro ao carregar usuário');
    } on DioException catch (e) {
      debugPrint('❌ Erro na requisição: ${e.message}');
      
      // Fallback com dados mockados
      return UserModel(
        id: '1',
        name: 'João da Silva',
        email: 'joao@example.com',
        cpf: '123.456.789-00',
        school: 'Escola Exemplo',
        matricula: '20260001',
        avatarUrl: 'https://i.pravatar.cc/300?img=12',
        balance: 58.40,
      );
    }
  }
}