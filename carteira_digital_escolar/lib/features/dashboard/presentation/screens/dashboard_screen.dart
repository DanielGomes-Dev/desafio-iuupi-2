import 'package:carteira_digital_escolar/features/auth/model/user_model.dart';
import 'package:carteira_digital_escolar/features/profile/repositories/profile_repository.dart';
import 'package:carteira_digital_escolar/features/transaction/data/repositories/transaction_repository.dart';
import 'package:carteira_digital_escolar/features/transaction/data/repositories/wallet_repository.dart';
import 'package:carteira_digital_escolar/features/transaction/presentation/screens/recharge_screen.dart';
import 'package:carteira_digital_escolar/features/transaction/presentation/screens/withdraw_screen.dart';
import 'package:flutter/material.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  final ProfileRepository? profileRepository;
  final StatementRepository? statementRepository;
  final WalletRepository? walletRepository;
  final void Function(int navIndex)? onNavigateToTab; // ✅

  const DashboardScreen({
    super.key,
    this.profileRepository,
    this.statementRepository,
    this.walletRepository,
    this.onNavigateToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ProfileRepository _profileRepository;
  late final StatementRepository _statementRepository;
  late final WalletRepository _walletRepository;

  // Estado da tela
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Dados carregados da API
  UserModel? _userProfile;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _profileRepository = widget.profileRepository ?? ProfileRepository();
    _statementRepository = widget.statementRepository ?? StatementRepository();
    _walletRepository = widget.walletRepository ?? WalletRepository();
    _loadData();
  }

  /// Carrega dados do usuário e transações em paralelo
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Busca em paralelo: perfil + transações
      final userFuture = _profileRepository.getCurrentUser();
      final transactionsFuture = _statementRepository.getTransactions();

      final user = await userFuture;
      final transactions = await transactionsFuture;

      if (!mounted) return;

      setState(() {
        _userProfile = user;
        _transactions = transactions.take(5).toList();
        _isLoading = false;
      });

      debugPrint('✅ Dashboard carregado com sucesso');
      debugPrint('👤 Usuário: ${user.name} | 💰 Saldo: R\$ ${user.balance}');
      debugPrint('📊 Transações carregadas: ${transactions.length}');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _formatError(e);
        _isLoading = false;
      });

      debugPrint('❌ Erro ao carregar dashboard: $e');
    }
  }

  /// Pull-to-refresh: recarrega dados
  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadData();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// Abre a tela de recarga
  Future<void> _openRecharge() async {
  if (_userProfile == null) return;

  final result = await Navigator.of(context).push<WalletOperationResult>(
    MaterialPageRoute(
      builder: (_) => RechargeScreen(
        profileRepository: _profileRepository,
        walletRepository: _walletRepository,
        onNavigateToTab: widget.onNavigateToTab, // ✅
      ),
    ),
  );

  if (result != null) _applyWalletResult(result);
}

  /// Abre a tela de saque
  Future<void> _openWithdraw() async {
    if (_userProfile == null) return;

    final result = await Navigator.of(context).push<WalletOperationResult>(
      MaterialPageRoute(
        builder: (_) => WithdrawScreen(
          currentBalance: _userProfile!.balance,
          repository: _walletRepository,
        ),
      ),
    );

    if (result != null) {
      _applyWalletResult(result);
    }
  }

  /// Atualiza o saldo e adiciona a nova transação no topo
  void _applyWalletResult(WalletOperationResult result) {
    setState(() {
      if (_userProfile != null) {
        // Cria um novo UserModel com saldo atualizado
        _userProfile = UserModel(
          id: _userProfile!.id,
          name: _userProfile!.name,
          email: _userProfile!.email,
          cpf: _userProfile!.cpf,
          school: _userProfile!.school,
          matricula: _userProfile!.matricula,
          avatarUrl: _userProfile!.avatarUrl,
          balance: result.balance, // ← Saldo atualizado
        );
      }

      // Insere a nova transação no topo e mantém apenas 5
      _transactions = [result.transaction, ..._transactions].take(5).toList();

      debugPrint(
        '✨ Transação aplicada! Novo saldo: R\$ ${_userProfile?.balance}',
      );
    });
  }

  /// Formata mensagens de erro de forma legível
  String _formatError(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('timeout')) {
      return 'Tempo limite excedido. Verifique sua conexão e tente novamente.';
    }
    if (message.contains('connection') || message.contains('offline')) {
      return 'Sem conexão com a internet. Verifique e tente novamente.';
    }
    if (message.contains('unauthorized') || message.contains('401')) {
      return 'Sessão expirada. Faça login novamente.';
    }
    return 'Não foi possível carregar o dashboard. Tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    // Estado de carregamento inicial
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Estado de erro e sem dados
    if (_errorMessage != null && _userProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _userProfile;
    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhum usuário carregado.'),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              // Cabeçalho com nome e avatar
              _Header(
                name: profile.name,
                school: profile.school,
                avatarUrl: profile.avatarUrl,
              ),
              const SizedBox(height: 24),

              // Card de saldo com botões de recarga/saque
              _BalanceCard(
                balance: profile.balance,
                onRecharge: _openRecharge,
                onWithdraw: _openWithdraw,
              ),
              const SizedBox(height: 28),

              // Seção de últimas movimentações
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimas movimentações',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_errorMessage != null)
                    Tooltip(
                      message: _errorMessage,
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista de transações ou mensagem vazia
              if (_transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Nenhuma movimentação encontrada.',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                )
              else
                ..._transactions.map((tx) {
                  return Column(
                    children: [
                      TransactionTile(
                        transaction: tx,
                        showFullDate: true,
                      ),
                      if (tx != _transactions.last) const Divider(height: 1),
                    ],
                  );
                }),

              const SizedBox(height: 8),

              // Botão para ver extrato completo
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navegar para statement_screen (índice 1 da navbar)
                    // Usar: DefaultTabController ou setState no HomePage
                  },
                  child: const Text('Ver extrato completo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget: Cabeçalho com nome, escola e avatar
class _Header extends StatelessWidget {
  final String name;
  final String school;
  final String? avatarUrl;

  const _Header({
    required this.name,
    required this.school,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${name.split(' ').first}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              school,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).dividerColor,
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : null,
          child: (avatarUrl == null || avatarUrl!.isEmpty)
              ? Icon(
                  Icons.person,
                  size: 28,
                  color: Theme.of(context).hintColor,
                )
              : null,
        ),
      ],
    );
  }
}

/// Widget: Card do saldo com gradiente e botões de ação
class _BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onRecharge;
  final VoidCallback onWithdraw;

  const _BalanceCard({
    required this.balance,
    required this.onRecharge,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B6EF6), Color(0xFFE0559E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo disponível',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.add,
                  label: 'Recarregar',
                  onTap: onRecharge,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.arrow_downward,
                  label: 'Sacar',
                  onTap: onWithdraw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget: Botão de ação (recarga/saque)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}