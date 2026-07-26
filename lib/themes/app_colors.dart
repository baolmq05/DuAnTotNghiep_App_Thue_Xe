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

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Primary / Brand colors - Giữ nguyên màu primary như yêu cầu của người dùng
  Color get primaryColor => AppColors.primary;
  Color get primaryDark => AppColors.primaryDark;
  Color get secondaryColor => AppColors.secondary;
  Color get accentSurface =>
      isDarkMode ? const Color(0xFF3B2F25) : AppColors.accentSurface;

  // Backgrounds - Sử dụng Colors.grey.shade900 làm nền và giảm dần cho thẻ
  Color get backgroundColor => colorScheme.surface;
  Color get cardColor => isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get scaffoldBackgroundColor =>
      isDarkMode ? Colors.grey.shade900 : const Color(0xFFF9FAFC);

  // Texts - Chữ luôn luôn là màu trắng ở Dark Mode
  Color get textPrimary => isDarkMode ? Colors.white : AppColors.textPrimary;
  Color get textSecondary =>
      isDarkMode ? Colors.white70 : AppColors.textSecondary;

  // Border
  Color get border => isDarkMode ? Colors.grey.shade800 : AppColors.border;

  // Status
  Color get success => isDarkMode ? const Color(0xFF4ADE80) : AppColors.success;
  Color get warning => isDarkMode ? const Color(0xFFFBBF24) : AppColors.warning;
  Color get error => colorScheme.error;
  Color get info => isDarkMode ? const Color(0xFF60A5FA) : AppColors.info;
}
