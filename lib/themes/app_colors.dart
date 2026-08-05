import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF286874);
  static const primaryDark = Color(0xFF10414F);
  static const secondary = Color(0xFFA77E52);
  static const accentSurface = Color(0xFFFEE3CE);

  // Background
  static const background = Color(0xFFFFFFFF);
  static const card = Color(0xFFF8F8F8);

  // Text
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);

  // Border
  static const border = Color(0xFFE5E7EB);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
}

extension AppThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  ThemeData get _theme => Theme.of(this);
  ColorScheme get colorScheme => _theme.colorScheme;

  // Primary / Brand colors
  Color get primaryColor => colorScheme.primary;
  Color get primaryDark => colorScheme.primaryContainer;
  Color get secondaryColor => colorScheme.secondary;
  Color get accentSurface => colorScheme.secondaryContainer;

  // Backgrounds
  Color get backgroundColor => colorScheme.surface;
  Color get cardColor => colorScheme.surfaceContainerHighest;
  Color get scaffoldBackgroundColor => _theme.scaffoldBackgroundColor;

  // Texts
  Color get textPrimary => colorScheme.onSurface;
  Color get textSecondary => colorScheme.onSurfaceVariant;

  // Border
  Color get border => colorScheme.outline;
  Color get borderVariant => colorScheme.outlineVariant;

  // Status
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get error => colorScheme.error;
  Color get info => AppColors.info;

  // Status Surfaces (used for order status badges etc.)
  Color get successSurface => isDarkMode ? const Color(0xFF1A3E26) : const Color(0xFFE8F5E9);
  Color get warningSurface => isDarkMode ? const Color(0xFF3E2C1A) : const Color(0xFFFFF3E0);
  Color get errorSurface => isDarkMode ? const Color(0xFF4A1F1F) : const Color(0xFFFFEBEE);
  Color get infoSurface => isDarkMode ? const Color(0xFF1E354A) : const Color(0xFFE3F2FD);

  // Alternate backgrounds & input fields
  Color get inputBackground => isDarkMode ? Colors.grey.shade800 : const Color(0xFFF9FAFB);
  Color get chatBubbleIncoming => isDarkMode ? Colors.grey.shade800 : const Color(0xFFF3F4F6);
}
