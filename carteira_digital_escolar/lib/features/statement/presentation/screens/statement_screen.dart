import 'package:flutter/material.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

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

  /// Converte mock para TransactionModel
  TransactionModel toModel(DateTime baseDate) => TransactionModel(
    id: title.hashCode ^ time.hashCode,
    type: type == _TxType.credit ? 'credit' : 'debit',
    description: title,
    amount: amount,
    createdAt: _parseMockDateTime(baseDate, time),
  );

  /// Parseia hora mockada
  static DateTime _parseMockDateTime(DateTime baseDate, String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }
}

class _MockGroup {
  final String label;
  final List<_MockTransaction> transactions;
  final DateTime date;

  const _MockGroup({
    required this.label,
    required this.transactions,
    required this.date,
  });
}

class _MockData {
  static final today = DateTime.now();
  static final yesterday = today.subtract(const Duration(days: 1));
  static final twoDaysAgo = today.subtract(const Duration(days: 2));

  static final groups = [
    _MockGroup(
      label: 'HOJE',
      date: today,
      transactions: [
        const _MockTransaction(
          title: 'Recarga de saldo',
          time: '14:30',
          amount: 50.00,
          type: _TxType.credit,
        ),
        const _MockTransaction(
          title: 'Lanche',
          time: '12:15',
          amount: 12.00,
          type: _TxType.debit,
        ),
      ],
    ),
    _MockGroup(
      label: 'ONTEM',
      date: yesterday,
      transactions: [
        const _MockTransaction(
          title: 'Refrigerante',
          time: '15:45',
          amount: 8.50,
          type: _TxType.debit,
        ),
        const _MockTransaction(
          title: 'Lanche',
          time: '10:00',
          amount: 10.00,
          type: _TxType.debit,
        ),
      ],
    ),
    _MockGroup(
      label: '04 AGO',
      date: twoDaysAgo,
      transactions: [
        const _MockTransaction(
          title: 'Material escolar',
          time: '11:30',
          amount: 15.00,
          type: _TxType.debit,
        ),
        const _MockTransaction(
          title: 'Recarga de saldo',
          time: '09:00',
          amount: 100.00,
          type: _TxType.credit,
        ),
        const _MockTransaction(
          title: 'Suco Natural',
          time: '15:15',
          amount: 6.00,
          type: _TxType.debit,
        ),
      ],
    ),
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

    final wantedType =
        _filter == _Filter.credito ? _TxType.credit : _TxType.debit;
    return _MockData.groups
        .map((g) => _MockGroup(
          label: g.label,
          date: g.date,
          transactions: g.transactions
              .where((t) => t.type == wantedType)
              .toList(),
        ))
        .where((g) => g.transactions.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // TODO: chamar repositório para buscar dados
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
                children: const [
                  Text(
                    'Extrato',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Filtros
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
            // Lista de transações
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  if (_filteredGroups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          'Nenhuma movimentação encontrada.',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ),
                    )
                  else
                    for (final group in _filteredGroups) ...[
                      // Label da data
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
                      // Transações do dia
                      ...group.transactions.map((mockTx) {
                        final tx = mockTx.toModel(group.date);
                        return Column(
                          children: [
                            TransactionTile(
                              transaction: tx,
                              showFullDate: false, // Mostra hora no statement
                              onTap: () {
                                // TODO: navegar para tela de detalhe
                              },
                            ),
                            if (mockTx != group.transactions.last)
                              const Divider(height: 1),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
      // Usa BottomNavBar compartilhada
      bottomNavigationBar: BottomNavBar(
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

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
              color: selected
                  ? Colors.transparent
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
