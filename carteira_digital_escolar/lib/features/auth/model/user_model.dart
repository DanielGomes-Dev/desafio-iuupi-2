class UserModel {
  final String id;
  final String name;
  final String email;
  final String cpf;
  final String school;
  final String matricula;
  final String? avatarUrl;
  final double balance;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.school,
    required this.matricula,
    this.avatarUrl,
    required this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cpf: json['cpf'] as String? ?? '',
      school: json['school'] as String? ?? 'Escola Exemplo',
      matricula: json['matricula'] as String? ?? json['enrollment'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'cpf': cpf,
    'school': school,
    'matricula': matricula,
    'avatar_url': avatarUrl,
    'balance': balance,
  };
}