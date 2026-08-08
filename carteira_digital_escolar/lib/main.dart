import 'package:carteira_digital_escolar/features/auth/controller/auth_controller.dart';
import 'package:carteira_digital_escolar/features/auth/presentation/screens/auth_gate_page.dart';
import 'package:carteira_digital_escolar/features/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {

// flutter pub add provider

  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => AuthController())
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Master Class',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGatePage(appWidget: (context) => const HomePage()),
    );
  }
}
