import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carteira_digital_escolar/core/network/token_storage.dart';
import 'package:carteira_digital_escolar/features/auth/model/user_model.dart';
import 'package:carteira_digital_escolar/features/auth/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  static const _userCacheKey = 'auth_user';
  static const _tokenCacheKey = 'auth_token';

  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _restoreSession();
  }

  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  /// Restaura sessão salva (token + usuário) ao abrir o app.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenCacheKey);
      final cachedUser = prefs.getString(_userCacheKey);

      if (token != null && cachedUser != null) {
        TokenStorage.instance.setToken(token);
        _user = UserModel.fromJson(jsonDecode(cachedUser));
      }
    } catch (e) {
      debugPrint('❌ Erro ao restaurar sessão: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Autentica na API e persiste token + usuário em cache.
  Future<void> login({required String cpf, required String password}) async {
    final result = await _authRepository.login(cpf: cpf, password: password);

    TokenStorage.instance.setToken(result.accessToken);
    _user = result.user;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenCacheKey, result.accessToken);
    await prefs.setString(_userCacheKey, jsonEncode(result.user.toJson()));
  }

  Future<void> logout() async {
    _user = null;
    TokenStorage.instance.setToken(null);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
    await prefs.remove(_tokenCacheKey);
  }
}