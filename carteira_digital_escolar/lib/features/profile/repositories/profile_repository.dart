import 'package:carteira_digital_escolar/features/auth/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({Dio? dio}) 
    : _dio = dio ?? Dio(BaseOptions(
        baseUrl: 'http://10.0.2.2:3001', // ← Android Emulator
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

  /// Buscar dados do usuário logado
  /// GET /me ← ENDPOINT CORRETO (não é /v1/user!)
  /// 
  /// ⚠️ IMPORTANTE: Este método NÃO faz fallback para mock!
  /// Se der erro, a exceção é lançada para o Dashboard tratar.
  Future<UserModel> getCurrentUser() async {
    try {
      debugPrint('🔄 Buscando usuário via GET /me...');
      
      final response = await _dio.get<Map<String, dynamic>>(
        '/me', // ← ENDPOINT CORRETO
        options: Options(
          headers: {
            'Authorization': 'Bearer desafio-mobile-token',
          },
        ),
      );

      debugPrint('📍 Status: ${response.statusCode}');
      debugPrint('📦 Dados: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data!);
        debugPrint('✅ Usuário carregado com SUCESSO: ${user.name}');
        debugPrint('💰 Saldo: R\$ ${user.balance}');
        return user;
      }

      throw Exception('Resposta vazia ou status inválido: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ ERRO na requisição (não há fallback!)');
      debugPrint('📌 Tipo: ${e.type}');
      debugPrint('📌 Mensagem: ${e.message}');
      debugPrint('📌 Response status: ${e.response?.statusCode}');
      debugPrint('📌 Response data: ${e.response?.data}');
      
      // ❌ IMPORTANTE: NÃO fazer fallback para mock!
      // Deixar a exceção ser lançada para o Dashboard tratar
      rethrow;
    } catch (e) {
      debugPrint('❌ ERRO desconhecido: $e');
      rethrow;
    }
  }
}