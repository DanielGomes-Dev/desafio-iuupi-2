import 'package:carteira_digital_escolar/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:carteira_digital_escolar/features/statement/presentation/screens/statement_screen.dart';
// TODO: Ajuste o caminho do import abaixo conforme a pasta onde você salvou o seu BottomNavBar
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

  // Lista com 4 telas correspondentes aos 4 itens da sua BottomNavBar
  final List<Widget> _pages = [
    const DashboardScreen(),
    const StatementScreen(),
    const Placeholder(), // Substitua pela tela de Recarga quando criar
    const Placeholder(), // Substitua pela tela de Perfil quando criar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      // Substituímos o BottomNavigationBar nativo pelo seu widget customizado
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}