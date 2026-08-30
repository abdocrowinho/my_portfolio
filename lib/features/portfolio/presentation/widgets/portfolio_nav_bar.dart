// Provides responsive in-page navigation for the public portfolio sections.
import 'package:abdelrhman_protfolio/core/responsive/responsive_layout.dart';
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PortfolioNavBar extends StatelessWidget {
  const PortfolioNavBar({required this.onNavigate, super.key});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      children: [
        const Text(
          'AO.',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (context.isDesktop) ...[
          _NavLink(label: 'About', index: 1, onNavigate: onNavigate),
          _NavLink(label: 'Stack', index: 2, onNavigate: onNavigate),
          _NavLink(label: 'Work', index: 3, onNavigate: onNavigate),
          _NavLink(label: 'Experience', index: 4, onNavigate: onNavigate),
          const SizedBox(width: 14),
        ],
        OutlinedButton(
          onPressed: () => onNavigate(5),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: const Text('Let\'s talk'),
        ),
      ],
    ),
  );
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.index,
    required this.onNavigate,
  });

  final String label;
  final int index;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => onNavigate(index), child: Text(label));
}
