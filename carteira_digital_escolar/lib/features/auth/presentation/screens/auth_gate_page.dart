import 'package:carteira_digital_escolar/features/auth/controller/auth_controller.dart';
import 'package:carteira_digital_escolar/features/auth/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class AuthGatePage extends StatelessWidget {
  final WidgetBuilder appWidget;
  const AuthGatePage({super.key, required this.appWidget});

  @override
  Widget build(BuildContext context) {

    AuthController authController = context.watch<AuthController>();

    if(!authController.isAuthenticated){
      // return AuthPage();
      return LoginScreen();

    }
    return appWidget(context);
  }
}