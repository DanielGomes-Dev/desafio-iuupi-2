import 'package:carteira_digital_escolar/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:carteira_digital_escolar/features/statement/presentation/screens/statement_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IUUPI',
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.light,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      // home: const LoginScreen(),
      // home: const DashboardScreen(),
      home: const StatementScreen(),
    );
  }
}