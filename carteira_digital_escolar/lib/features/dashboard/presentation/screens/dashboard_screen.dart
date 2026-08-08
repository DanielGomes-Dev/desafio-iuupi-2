import 'package:flutter/material.dart';


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
}

class _MockData {
  static const userName = 'João';
  static const school = 'Escola Exemplo';
  static const balance = 58.40;
  static const avatarUrl = 'https://i.pravatar.cc/300?img=12';

  static const transactions = [
    _MockTransaction(
        title: 'Recarga de saldo', date: 'Hoje', amount: 50.00, type: _TxType.credit),
    _MockTransaction(title: 'Lanche', date: 'Hoje', amount: 12.00, type: _TxType.debit),
    _MockTransaction(
        title: 'Refrigerante', date: 'Ontem', amount: 8.50, type: _TxType.debit),
    _MockTransaction(
        title: 'Material escolar', date: '04 Ago', amount: 15.00, type: _TxType.debit),
    _MockTransaction(
        title: 'Recarga de saldo', date: '02 Ago', amount: 100.00, type: _TxType.credit),
  ];
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _Header(name: _MockData.userName, school: _MockData.school),
            const SizedBox(height: 24),
            _BalanceCard(balance: _MockData.balance),
            const SizedBox(height: 28),
            const Text(
              'Últimas movimentações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._MockData.transactions.map((t) => Column(
                  children: [
                    _TransactionTile(transaction: t),
                    if (t != _MockData.transactions.last) const Divider(height: 1),
                  ],
                )),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Ver extrato completo'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
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

  const _BalanceCard({required this.balance});

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
          const Text('Saldo disponível', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _ActionButton(icon: Icons.add, label: 'Recarregar', onTap: () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionButton(icon: Icons.arrow_downward, label: 'Sacar', onTap: () {})),
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

  const _ActionButton({required this.icon, required this.label, required this.onTap});

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
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _MockTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == _TxType.credit;
    final color = isCredit ? Colors.green : Colors.red;
    final valor = 'R\$ ${transaction.amount.toStringAsFixed(2).replaceAll('.', ',')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCredit ? const Color(0xFFE3F8E9) : const Color(0xFFFDE9E7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(transaction.date,
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
              ],
            ),
          ),
          Text(
            isCredit ? '+$valor' : '-$valor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Início'),
    (icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Extrato'),
    (icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Recarga'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = index == currentIndex;
          final color = selected ? const Color(0xFF6C63FF) : Theme.of(context).hintColor;

          return InkWell(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(item.label,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
              ],
            ),
          );
        }),
      ),
    );
  }
}