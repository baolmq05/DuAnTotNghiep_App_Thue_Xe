import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    outline: AppColors.border,
  ),
);
