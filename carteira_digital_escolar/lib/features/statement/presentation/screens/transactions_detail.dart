import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/transaction_model.dart';

/// Tela de detalhes de uma transação, aberta ao tocar em um item
/// do Dashboard ou do Extrato.
///
/// Recebe a [TransactionModel] já carregada pela lista de origem,
/// então não depende de nenhuma nova chamada de API para exibir os
/// dados imediatamente.
class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  static const _creditColor = Color(0xFF16C784);
  static const _creditBgColor = Color(0xFFE3F8E9);
  static const _debitColor = Color(0xFFE0554F);
  static const _debitBgColor = Color(0xFFFDE9E7);

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final statusColor = isCredit ? _creditColor : _debitColor;
    final statusBgColor = isCredit ? _creditBgColor : _debitBgColor;
    final statusLabel = isCredit ? 'Crédito Recebido' : 'Débito Realizado';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalhes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: statusBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.check : Icons.close,
                  color: statusColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'R\$ ${transaction.amount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Descrição',
                      value: transaction.description,
                    ),
                    const Divider(height: 1, color: AppColors.inputBorder),
                    _DetailRow(
                      label: 'Data e Hora',
                      value: _formatDateTime(transaction.createdAt),
                    ),
                    const Divider(height: 1, color: AppColors.inputBorder),
                    _DetailRow(
                      label: 'ID da transação',
                      value: '#${transaction.id}',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$minute';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLast ? 18 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}