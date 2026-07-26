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

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary, // Giữ nguyên màu primary cho nút/thành phần
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    surface: Colors.grey.shade900, // Nền là grey.shade900
    onSurface: Colors.white, // Chữ luôn là màu trắng
    onSurfaceVariant: Colors.white70, // Chữ phụ màu trắng mờ
    error: AppColors.error,
    outline: Colors.grey.shade800, // Đường viền tối
  ),
);
