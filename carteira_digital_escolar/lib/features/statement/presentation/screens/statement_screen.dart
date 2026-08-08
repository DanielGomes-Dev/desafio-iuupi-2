import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// Versão 100% visual da tela de Extrato, sem nenhuma chamada de rede.
/// Os dados abaixo são mockados e já vêm agrupados por data
/// (Hoje / Ontem / 04 Ago) só para preencher o layout.
/// ---------------------------------------------------------------------

enum _TxType { credit, debit }

class _MockTransaction {
  final String title;
  final String time;
  final double amount;
  final _TxType type;

  const _MockTransaction({
    required this.title,
    required this.time,
    required this.amount,
    required this.type,
  });
}

class _MockGroup {
  final String label;
  final List<_MockTransaction> transactions;

  const _MockGroup({required this.label, required this.transactions});
}

class _MockData {
  static const groups = [
    _MockGroup(label: 'HOJE', transactions: [
      _MockTransaction(
          title: 'Recarga de saldo', time: '14:30', amount: 50.00, type: _TxType.credit),
      _MockTransaction(title: 'Lanche', time: '12:15', amount: 12.00, type: _TxType.debit),
    ]),
    _MockGroup(label: 'ONTEM', transactions: [
      _MockTransaction(
          title: 'Refrigerante', time: '15:45', amount: 8.50, type: _TxType.debit),
      _MockTransaction(title: 'Lanche', time: '10:00', amount: 10.00, type: _TxType.debit),
    ]),
    _MockGroup(label: '04 AGO', transactions: [
      _MockTransaction(
          title: 'Material escolar', time: '11:30', amount: 15.00, type: _TxType.debit),
      _MockTransaction(
          title: 'Recarga de saldo', time: '09:00', amount: 100.00, type: _TxType.credit),
      _MockTransaction(
          title: 'Suco Natural', time: '15:15', amount: 6.00, type: _TxType.debit),
    ]),
  ];
}

enum _Filter { todos, credito, debito }

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  _Filter _filter = _Filter.todos;
  int _navIndex = 1;

  List<_MockGroup> get _filteredGroups {
    if (_filter == _Filter.todos) return _MockData.groups;

    final wantedType = _filter == _Filter.credito ? _TxType.credit : _TxType.debit;
    return _MockData.groups
        .map((g) => _MockGroup(
              label: g.label,
              transactions: g.transactions.where((t) => t.type == wantedType).toList(),
            ))
        .where((g) => g.transactions.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  const Text('Extrato',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _filter == _Filter.todos,
                    onTap: () => setState(() => _filter = _Filter.todos),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Crédito',
                    selected: _filter == _Filter.credito,
                    onTap: () => setState(() => _filter = _Filter.credito),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Débito',
                    selected: _filter == _Filter.debito,
                    onTap: () => setState(() => _filter = _Filter.debito),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  for (final group in _filteredGroups) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        group.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    ...group.transactions.map((t) => Column(
                          children: [
                            _TransactionTile(transaction: t),
                            if (t != group.transactions.last)
                              const Divider(height: 1),
                          ],
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (_filteredGroups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text('Nenhuma movimentação encontrada.',
                            style: TextStyle(color: Theme.of(context).hintColor)),
                      ),
                    ),
                ],
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF6C63FF) : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.transparent : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
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
                Text(transaction.time,
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