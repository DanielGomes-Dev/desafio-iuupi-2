import 'package:flutter/material.dart';

/// Widget reutilizável para navbar inferior.
/// Centraliza a lógica de navegação entre dashboard, statement, wallet e profile.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Itens da navbar com ícones outlined/filled e labels
  static const _items = [
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Início',
    ),
    (
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Extrato',
    ),
    (
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Recarga',
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = index == currentIndex;
          final color = isSelected
              ? const Color(0xFF6C63FF) // Cor ativa (roxo)
              : Theme.of(context).hintColor; // Cor inativa

          return InkWell(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
