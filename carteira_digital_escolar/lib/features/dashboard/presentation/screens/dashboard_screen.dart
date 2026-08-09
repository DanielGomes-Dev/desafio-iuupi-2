import 'package:carteira_digital_escolar/features/transaction/data/repositories/wallet_repository.dart';
import 'package:carteira_digital_escolar/features/transaction/presentation/screens/recharge_screen.dart';
import 'package:carteira_digital_escolar/features/transaction/presentation/screens/withdraw_screen.dart';
import 'package:flutter/material.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/widgets/transaction_tile.dart';


enum _TxType { credit, debit }

class _MockTransaction {
  final String title;
  final String date;
  final double amount;
  final _TxType type;

  const _MockTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });

  /// Converte mock para TransactionModel
  TransactionModel toModel() => TransactionModel(
    id: title.hashCode,
    type: type == _TxType.credit ? 'credit' : 'debit',
    description: title,
    amount: amount,
    createdAt: _parseMockDate(date),
  );

  /// Helper para parsear datas mockadas
  static DateTime _parseMockDate(String dateStr) {
    final now = DateTime.now();
    if (dateStr == 'Hoje') {
      return now;
    } else if (dateStr == 'Ontem') {
      return now.subtract(const Duration(days: 1));
    } else {
      // "04 Ago" → parse simplificado
      return now;
    }
  }
}

class _MockData {
  static const userName = 'João';
  static const school = 'Escola Exemplo';
  static const balance = 58.40;
  static const avatarUrl = 'https://i.pravatar.cc/300?img=12';

  static const transactions = [
    _MockTransaction(
      title: 'Recarga de saldo',
      date: 'Hoje',
      amount: 50.00,
      type: _TxType.credit,
    ),
    _MockTransaction(
      title: 'Lanche',
      date: 'Hoje',
      amount: 12.00,
      type: _TxType.debit,
    ),
    _MockTransaction(
      title: 'Refrigerante',
      date: 'Ontem',
      amount: 8.50,
      type: _TxType.debit,
    ),
    _MockTransaction(
      title: 'Material escolar',
      date: '04 Ago',
      amount: 15.00,
      type: _TxType.debit,
    ),
    _MockTransaction(
      title: 'Recarga de saldo',
      date: '02 Ago',
      amount: 100.00,
      type: _TxType.credit,
    ),
  ];
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  final WalletRepository _walletRepository = WalletRepository();

  // Estado mutável: começa a partir do mock, mas é atualizado de verdade
  // quando uma recarga/saque é concluída.
  double _balance = _MockData.balance;
  List<TransactionModel> _transactions =
      _MockData.transactions.map((mockTx) => mockTx.toModel()).toList();

  Future<void> _openRecharge() async {
    final result = await Navigator.of(context).push<WalletOperationResult>(
      MaterialPageRoute(
        builder: (_) => RechargeScreen(
          currentBalance: _balance,
          repository: _walletRepository,
        ),
      ),
    );

    if (result != null) {
      _applyWalletResult(result);
    }
  }

  Future<void> _openWithdraw() async {
    final result = await Navigator.of(context).push<WalletOperationResult>(
      MaterialPageRoute(
        builder: (_) => WithdrawScreen(
          currentBalance: _balance,
          repository: _walletRepository,
        ),
      ),
    );

    if (result != null) {
      _applyWalletResult(result);
    }
  }

  /// Atualiza o saldo exibido e insere a nova transação no topo do extrato,
  /// sem precisar buscar tudo de novo na API.
  void _applyWalletResult(WalletOperationResult result) {
    setState(() {
      _balance = result.balance;
      _transactions = [result.transaction, ..._transactions];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dashboard mostra só as 5 movimentações mais recentes.
    final recentTransactions = _transactions.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _Header(name: _MockData.userName, school: _MockData.school),
            const SizedBox(height: 24),
            _BalanceCard(
              balance: _balance,
              onRecharge: _openRecharge,
              onWithdraw: _openWithdraw,
            ),
            const SizedBox(height: 28),
            const Text(
              'Últimas movimentações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Usa TransactionTile compartilhado
            ...recentTransactions.map((tx) {
              return Column(
                children: [
                  TransactionTile(
                    transaction: tx,
                    showFullDate: true,
                  ),
                  if (tx != recentTransactions.last) const Divider(height: 1),
                ],
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: navegar para statement_screen
                },
                child: const Text('Ver extrato completo'),
              ),
            ),
          ],
        ),
      ),
      // Usa BottomNavBar compartilhada
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String school;

  const _Header({required this.name, required this.school});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, $name!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(school, style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).dividerColor,
          backgroundImage: const NetworkImage(_MockData.avatarUrl),
        ),
      ],
    );
  }
}

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