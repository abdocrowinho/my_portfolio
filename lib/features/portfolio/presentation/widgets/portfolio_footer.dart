// Closes the public portfolio with a small ownership statement.
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PortfolioFooter extends StatelessWidget {
  const PortfolioFooter({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 30),
    child: Text(
      '© 2026 Abdelrahman Osama Mohamed',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
    ),
  );
}
