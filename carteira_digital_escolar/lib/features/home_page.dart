import 'package:carteira_digital_escolar/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:carteira_digital_escolar/features/statement/presentation/screens/statement_screen.dart';
import 'package:carteira_digital_escolar/features/profile/presentation/screens/profile_screen.dart';
import 'package:carteira_digital_escolar/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ✅ ATUALIZADO: Adicione ProfileScreen
  final List<Widget> _pages = [
    const DashboardScreen(),      // Índice 0: Início
    const StatementScreen(),       // Índice 1: Extrato
    const Placeholder(
      child: Center(
        child: Text('Tela de Recarga - Em desenvolvimento'),
      ),
    ), // Índice 2: Recarga (em breve)
    const ProfileScreen(),         // Índice 3: Perfil ✅ NOVO
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}