import 'dart:convert';
import 'package:carteira_digital_escolar/features/auth/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  static const _cacheKey = 'auth_user';

  User? _user;
  bool _isLoading = true; // true enquanto verifica o cache no início

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthController() {
    _restoreSession();
  }

  /// Verifica se existe um usuário salvo em cache (chamado 1x ao abrir o app)
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        _user = User.fromJson(jsonDecode(cached));
      }
    } catch (e) {
      debugPrint('❌ Erro ao restaurar sessão: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Autentica o usuário e salva em cache
  Future<void> login(User user) async {
    _user = user;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(user.toJson()));
  }

  /// Encerra a sessão e limpa o cache
  Future<void> logout() async {
    _user = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}