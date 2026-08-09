import 'package:carteira_digital_escolar/features/auth/model/user_model.dart';
import 'package:carteira_digital_escolar/features/profile/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  /// Repositório injetável para testes
  final ProfileRepository? profileRepository;

  const ProfileScreen({
    super.key,
    this.profileRepository,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Estado
  UserModel? _user;
  bool _loading = true;
  String? _error;

  late ProfileRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.profileRepository ?? ProfileRepository();
    _loadUser();
  }

  /// Carregar dados do usuário
  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await _repository.getCurrentUser();
      setState(() {
        _user = user;
        _loading = false;
      });
      debugPrint('✅ Perfil carregado: ${user.name}');
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar perfil: $e';
        _loading = false;
      });
      debugPrint('❌ Erro ao carregar perfil: $e');
    }
  }

  /// Fazer logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Tem certeza que deseja fazer logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async  {
              // Chama logout no AuthController (via Provider)
              await context.read<AuthController>().logout();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadUser,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : _user != null
                    ? Column(
                        children: [
                          // Cabeçalho com avatar e nome
                          _buildHeader(_user!),

                          // Informações do usuário
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  _buildInfoCard('Escola', _user!.school),
                                  const SizedBox(height: 16),
                                  _buildInfoCard('Matrícula', _user!.matricula),
                                  const SizedBox(height: 16),
                                  _buildInfoCard('CPF', _user!.cpf),
                                  const SizedBox(height: 16),
                                  _buildInfoCard(
                                    'Saldo',
                                    'R\$ ${_user!.balance.toStringAsFixed(2).replaceAll('.', ',')}',
                                    isBalance: true,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Botão Sair
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleLogout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFE5E5),
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Sair da conta'),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(child: Text('Nenhum usuário encontrado')),
      ),
    );
  }

  /// Widget: Cabeçalho com avatar
  Widget _buildHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          const SizedBox(height: 16),
          // Nome
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget: Card de informação
  Widget _buildInfoCard(
    String label,
    String value, {
    bool isBalance = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBalance
            ? AppColors.primary.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBalance
              ? AppColors.primary
              : AppColors.inputBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isBalance ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (isBalance)
            Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }
}