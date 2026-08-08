import 'package:carteira_digital_escolar/features/auth/model/user.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier { //Padrao Observer (instalar o provider)
// flutter pub add provider
  User? _user = User(
    id: '1',
    name: 'Leonardo Leitão',
    email: 'leonardo@example.com',
  );

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // Function login
  // Function logout
  // Function register

  void logout() {
    _user = null;
    notifyListeners();
  }
}