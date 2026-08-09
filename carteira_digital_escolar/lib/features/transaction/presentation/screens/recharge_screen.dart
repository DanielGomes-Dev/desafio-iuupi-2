import 'package:carteira_digital_escolar/features/profile/repositories/profile_repository.dart';
import 'package:carteira_digital_escolar/features/transaction/data/repositories/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

/// Tela de recarga de saldo.
///
/// ✅ IMPORTANTE: Agora busca o saldo atual da API (ProfileRepository)
/// em vez de receber via parâmetro.
///
/// Fluxo:
/// 1. Carrega saldo atual via ProfileRepository.getCurrentUser()
/// 2. Usuário insere valor de recarga
/// 3. Confirma e faz POST /transactions (WalletRepository.recharge)
/// 4. Retorna resultado para Dashboard via Navigator.pop(result)
class RechargeScreen extends StatefulWidget {
  /// Repositórios injetáveis
  final ProfileRepository? profileRepository;
  final WalletRepository? walletRepository;

  const RechargeScreen({
    super.key,
    this.profileRepository,
    this.walletRepository,
  });

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  static const _quickAmountsInCents = [1000, 2000, 5000, 10000];

  late final ProfileRepository _profileRepository;
  late final WalletRepository _walletRepository;

  // Estado de carregamento do saldo
  bool _isLoadingBalance = true;
  double _currentBalance = 0.0;
  String? _errorLoadingBalance;

  // Estado de submissão da recarga
  bool _isSubmitting = false;
  String? _errorMessage;

  // Controllers
  final _amountController = TextEditingController(text: '50,00');
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileRepository = widget.profileRepository ?? ProfileRepository();
    _walletRepository = widget.walletRepository ?? WalletRepository();
    _loadCurrentBalance();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Carrega o saldo atual da API
  Future<void> _loadCurrentBalance() async {
    setState(() {
      _isLoadingBalance = true;
      _errorLoadingBalance = null;
    });

    try {
      debugPrint('🔄 Carregando saldo atual...');
      final user = await _profileRepository.getCurrentUser();

      setState(() {
        _currentBalance = user.balance;
        _isLoadingBalance = false;
      });

      debugPrint('✅ Saldo carregado: R\$ ${_currentBalance.toStringAsFixed(2)}');
    } catch (e) {
      setState(() {
        _errorLoadingBalance = 'Erro ao carregar saldo: $e';
        _isLoadingBalance = false;
      });

      debugPrint('❌ Erro ao carregar saldo: $e');
    }
  }

  double get _amountValue {
    final raw = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  void _setAmountCents(int cents) {
    setState(() {
      _amountController.text = _formatCentsToText(cents);
      _errorMessage = null;
    });
  }

  Future<void> _handleConfirm() async {
    if (_amountValue <= 0) {
      setState(() => _errorMessage = 'Informe um valor maior que zero.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      debugPrint('💳 Processando recarga de R\$ ${_amountValue.toStringAsFixed(2)}...');

      final result = await _walletRepository.recharge(
        amount: _amountValue,
        description: _descriptionController.text,
      );

      if (!mounted) return;

      debugPrint('✅ Recarga realizada! Novo saldo: R\$ ${result.balance}');

      await _showSuccessDialog(result.balance);

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on WalletApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isSubmitting = false;
      });
      debugPrint('❌ Erro na recarga: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Não foi possível concluir a recarga. Tente novamente.';
        _isSubmitting = false;
      });
      debugPrint('❌ Erro desconhecido: $e');
    }
  }

  Future<void> _showSuccessDialog(double newBalance) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F8E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Color(0xFF16C784), size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recarga realizada!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Novo saldo: R\$ ${newBalance.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Estado: Carregando saldo
    if (_isLoadingBalance) {
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
            'Recarga',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Estado: Erro ao carregar saldo
    if (_errorLoadingBalance != null) {
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
            'Recarga',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
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
                  _errorLoadingBalance!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCurrentBalance,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Estado: Normal (com saldo carregado)
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
          'Recarga',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Saldo carregado da API
                    Row(
                      children: [
                        const Text(
                          'Saldo atual: ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'R\$ ${_currentBalance.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    const Center(
                      child: Text(
                        'VALOR DA RECARGA',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CentavosInputFormatter(),
                      ],
                      onChanged: (_) => setState(() => _errorMessage = null),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        prefixText: 'R\$ ',
                        prefixStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Quick amount chips
                    Row(
                      children: _quickAmountsInCents
                          .map(
                            (cents) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _QuickAmountChip(
                                  label: 'R\$ ${cents ~/ 100}',
                                  onTap: () => _setAmountCents(cents),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Descrição (opcional)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Dinheiro para o passeio',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleConfirm,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirmar recarga'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCentsToText(int cents) {
    final reais = cents ~/ 100;
    final centavos = (cents % 100).toString().padLeft(2, '0');
    return '${_formatThousands(reais)},$centavos';
  }
}

String _formatThousands(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class _CentavosInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) digits = '0';
    if (digits.length > 9) digits = digits.substring(digits.length - 9);

    final value = int.parse(digits);
    final reais = value ~/ 100;
    final centavos = (value % 100).toString().padLeft(2, '0');
    final formatted = '${_formatThousands(reais)},$centavos';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}