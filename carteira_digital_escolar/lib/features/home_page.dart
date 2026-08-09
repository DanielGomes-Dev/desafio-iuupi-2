import 'package:carteira_digital_escolar/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:carteira_digital_escolar/features/profile/repositories/profile_repository.dart';
import 'package:carteira_digital_escolar/features/profile/presentation/screens/profile_screen.dart';
import 'package:carteira_digital_escolar/features/transaction/data/repositories/transaction_repository.dart';
import 'package:carteira_digital_escolar/features/transaction/data/repositories/wallet_repository.dart';
import 'package:carteira_digital_escolar/features/transaction/presentation/screens/recharge_screen.dart';
import 'package:carteira_digital_escolar/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:carteira_digital_escolar/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // ✅ Instanciar repositórios uma única vez
  // Se usar GetIt ou Provider, coloque isso em main.dart
  late final ProfileRepository _profileRepository;
  late final StatementRepository _statementRepository;
  late final WalletRepository _walletRepository;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
  }

  void _selectTab(int navIndex) {
    setState(() {
      _selectedIndex = _pageIndexForNavIndex(navIndex);
    });
  }


  /// Inicializar repositórios
  /// Se usar Provider/GetIt, mova isso para main.dart
  void _initializeRepositories() {
    _profileRepository = ProfileRepository();
    _statementRepository = StatementRepository();
    _walletRepository = WalletRepository();
  }


  late final List<Widget> _pages = [
    // Índice 0: Dashboard com repositórios injetados
    DashboardScreen(
      profileRepository: _profileRepository,
      statementRepository: _statementRepository,
      walletRepository: _walletRepository,
      onNavigateToTab: _selectTab,

    ),

    // Índice 1: Extrato com repositório injetado
    StatementScreen(
      repository: _statementRepository,
    ),

    // Índice 2: Perfil com repositório injetado
    ProfileScreen(
      profileRepository: _profileRepository,
    ),
  ];

  int _pageIndexForNavIndex(int navIndex) {

    if (navIndex == 3) return 2;
    return navIndex;
  }


    void _onItemTapped(int index) {
      if (index == 2) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RechargeScreen(
              profileRepository: _profileRepository,
              walletRepository: _walletRepository,
              onNavigateToTab: _selectTab, // ✅
            ),
          ),
        );
        return;
      }
      _selectTab(index);
    }


  int get _currentNavIndex => _selectedIndex == 2 ? 3 : _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}