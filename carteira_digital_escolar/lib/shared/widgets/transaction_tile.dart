import 'package:carteira_digital_escolar/features/statement/presentation/screens/transactions_detail.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  /// Callback opcional, chamado *depois* de abrir a tela de detalhes.
  /// Útil para efeitos colaterais (ex.: analytics), sem precisar
  /// reimplementar a navegação em cada tela que usa o TransactionTile.
  final VoidCallback? onTap;

  final bool showFullDate;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showFullDate = true,
  });

  void _handleTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? Colors.green : Colors.red;
    final bgColor = isCredit 
        ? const Color(0xFFE3F8E9) // verde claro
        : const Color(0xFFFDE9E7); // vermelho claro

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Ícone circular
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Título e data/hora
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(context),
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Valor
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formata a data dependendo do contexto
  String _formatDate(BuildContext context) {
    if (!showFullDate) {
      // Retorna apenas a hora (para statement)
      return '${transaction.createdAt.hour.toString().padLeft(2, '0')}:${transaction.createdAt.minute.toString().padLeft(2, '0')}';
    }

    // Retorna data relativa (hoje, ontem, data) - para dashboard
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(
      transaction.createdAt.year,
      transaction.createdAt.month,
      transaction.createdAt.day,
    );

    if (txDate == today) {
      return 'Hoje';
    } else if (txDate == yesterday) {
      return 'Ontem';
    } else {
      // Formato: 04 Ago
      final months = [
        '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
      ];
      return '${transaction.createdAt.day.toString().padLeft(2, '0')} ${months[transaction.createdAt.month]}';
    }
  }
}