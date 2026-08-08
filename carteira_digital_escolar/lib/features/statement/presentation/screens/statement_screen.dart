import 'package:dio/dio.dart';
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

  TransactionModel toModel(DateTime baseDate) => TransactionModel(
        id: title.hashCode ^ time.hashCode,
        type: type == _TxType.credit ? 'credit' : 'debit',
        description: title,
        amount: amount,
        createdAt: _parseMockDateTime(baseDate, time),
      );

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

  static List<TransactionModel> get fallbackTransactions {
    List<TransactionModel> list = [];
    for (var group in groups) {
      for (var tx in group.transactions) {
        list.add(tx.toModel(group.date));
      }
    }
    return list;
  }
}

enum _Filter { todos, credito, debito }

class DisplayGroup {
  final String label;
  final List<TransactionModel> transactions;

  DisplayGroup({required this.label, required this.transactions});
}

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  _Filter _filter = _Filter.todos;
  int _navIndex = 1;

  List<TransactionModel> _transactions = [];
  bool isLoading = false;
  bool isUsingMock = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _onFilterChanged(_Filter newFilter) {
    setState(() {
      _filter = newFilter;
    });
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> queryParams = {};
    if (_filter == _Filter.credito) {
      queryParams['type'] = 'credit';
    } else if (_filter == _Filter.debito) {
      queryParams['type'] = 'debit';
    }

    try {
      final response = await Dio().get(
        'http://10.0.2.2:3001/transactions',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer desafio-mobile-token',
          },
        ),
      );

      // 🎯 Acessa diretamente a chave "data" da resposta JSON
      final List listData = response.data['data'] as List;

      setState(() {
        _transactions = listData
            .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        isUsingMock = false;
        isLoading = false;
      });

      debugPrint('🎉 CONECTADO COM SUCESSO NA API! Total: ${_transactions.length}');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro na requisição: $e');
      
      // Fallback do mock continua aqui intacto...
      List<TransactionModel> fallback = _MockData.fallbackTransactions;
      if (_filter == _Filter.credito) {
        fallback = fallback.where((t) => t.type == 'credit').toList();
      } else if (_filter == _Filter.debito) {
        fallback = fallback.where((t) => t.type == 'debit').toList();
      }

      setState(() {
        _transactions = fallback;
        isUsingMock = true;
        isLoading = false;
      });
    }
  }
  List<DisplayGroup> get _groupedTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    Map<String, List<TransactionModel>> groupsMap = {};

    for (var tx in _transactions) {
      final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
      String label;

      if (txDate.isAtSameMomentAs(today)) {
        label = 'HOJE';
      } else if (txDate.isAtSameMomentAs(yesterday)) {
        label = 'ONTEM';
      } else {
        label = '${tx.createdAt.day.toString().padLeft(2, '0')}/${tx.createdAt.month.toString().padLeft(2, '0')}';
      }

      if (!groupsMap.containsKey(label)) {
        groupsMap[label] = [];
      }
      groupsMap[label]!.add(tx);
    }

    return groupsMap.entries
        .map((entry) => DisplayGroup(label: entry.key, transactions: entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedTransactions;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Extrato',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  if (isUsingMock)
                    const Chip(
                      label: Text('Modo Offline/Mock', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.orangeAccent,
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
                    onTap: () => _onFilterChanged(_Filter.todos),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Crédito',
                    selected: _filter == _Filter.credito,
                    onTap: () => _onFilterChanged(_Filter.credito),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Débito',
                    selected: _filter == _Filter.debito,
                    onTap: () => _onFilterChanged(_Filter.debito),
                  ),
                ],
              ),
            ),
            // Lista de transações
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        if (groups.isEmpty)
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
                          for (final group in groups) ...[
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
                            ...group.transactions.map((tx) {
                              return Column(
                                children: [
                                  TransactionTile(
                                    transaction: tx,
                                    showFullDate: false,
                                    onTap: () {
                                      // TODO: navegar para tela de detalhe
                                    },
                                  ),
                                  if (tx != group.transactions.last)
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