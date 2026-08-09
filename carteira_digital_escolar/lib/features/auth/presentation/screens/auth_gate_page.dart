import 'package:carteira_digital_escolar/features/auth/controller/auth_controller.dart';
import 'package:carteira_digital_escolar/features/auth/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class AuthGatePage extends StatelessWidget {
  final WidgetBuilder appWidget;
  const AuthGatePage({super.key, required this.appWidget});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    // Enquanto verifica se há sessão salva em cache
    if (authController.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authController.isAuthenticated) {
      return const LoginScreen();
    }

    return appWidget(context);
  }
}