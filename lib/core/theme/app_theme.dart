// Builds the visual theme shared by every public portfolio page.
import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 64,
        fontWeight: FontWeight.w800,
        height: 1.04,
        letterSpacing: -1.8,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 1.14,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 17,
        height: 1.65,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.55,
      ),
    ),
  );
}
