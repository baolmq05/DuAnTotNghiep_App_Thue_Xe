import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.accentSurface,
    surface: AppColors.background,
    surfaceContainerHighest: AppColors.card,   // card color
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    outline: AppColors.border,
    outlineVariant: Color(0xFFF0F0F0),
  ),
  scaffoldBackgroundColor: const Color(0xFFF9FAFC),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF9FAFC),
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.border,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: AppColors.textSecondary,
    dividerColor: Colors.transparent,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Colors.white,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    secondaryContainer: const Color(0xFF3B2F25),  // accentSurface dark
    surface: Colors.grey.shade900,
    surfaceContainerHighest: Colors.grey.shade800,  // card color
    onSurface: Colors.white,
    onSurfaceVariant: Colors.white70,
    error: AppColors.error,
    outline: Colors.grey.shade800,
    outlineVariant: Colors.grey.shade700,
  ),
  scaffoldBackgroundColor: Colors.grey.shade900,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade900,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.grey.shade800,
    elevation: 0,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade800,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade800,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white70,
    dividerColor: Colors.transparent,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.grey.shade800,
  ),
);
