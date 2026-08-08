/// Modelo genérico de transação com suporte a ambos os contextos
/// (dashboard com data relativa e statement com datetime completo)
class TransactionModel {
  final int id;
  final String type; // 'credit' ou 'debit'
  final String description;
  final double amount; // em centavos na API, convertido para double
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'description': description,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'] as int,
    type: json['type'] as String,
    description: json['description'] as String,
    amount: (json['amount'] as num).toDouble() / 100, // Converte centavos
    createdAt: json['created_at'] is String
        ? DateTime.parse(json['created_at'] as String)
        : json['created_at'] as DateTime,
  );

  /// Helper: retorna true se é crédito
  bool get isCredit => type.toLowerCase() == 'credit';

  /// Helper: retorna true se é débito
  bool get isDebit => type.toLowerCase() == 'debit';

  /// Helper: formata o valor em R$
  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign R\$ ${(amount.abs()).toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Helper: retorna a cor baseada no tipo
  String get typeLabel => isCredit ? 'Crédito' : 'Débito';
}
