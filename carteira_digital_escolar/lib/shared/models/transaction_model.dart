class TransactionModel {
  final int id;
  final String type;
  final String description;
  final double amount;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'amount': (amount * 100).toInt(), // Converte de volta para centavos
        'created_at': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Parse do ID (aceita int ou String)
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    // Parse da Data
    final rawDate = json['created_at'] ?? json['createdAt'];
    DateTime parsedDate = rawDate is String 
        ? (DateTime.tryParse(rawDate) ?? DateTime.now()) 
        : DateTime.now();

    // Parse do Valor (pega como double direto, sem dividir por 100)
    final rawAmount = json['amount'];
    double parsedAmount = 0.0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    }

    return TransactionModel(
      id: parsedId,
      type: json['type'] as String? ?? 'debit',
      description: json['description'] as String? ?? '',
      amount: parsedAmount,
      createdAt: parsedDate,
    );
  }

  // Permite criar o objeto a partir de outro map (compatibilidade)
  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel.fromJson(map);

  bool get isCredit => type.toLowerCase() == 'credit';

  bool get isDebit => type.toLowerCase() == 'debit';

  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign R\$ ${(amount.abs()).toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get typeLabel => isCredit ? 'Crédito' : 'Débito';
}