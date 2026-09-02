import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class NoInternetScreen extends StatelessWidget {
  final Future<void> Function() onRetry;
  final bool isChecking;

  const NoInternetScreen({
    super.key,
    required this.onRetry,
    this.isChecking = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minimalist compact icon container with soft brand tint
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? context.primaryColor.withValues(alpha: 0.15)
                        : context.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 34,
                      color: context.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Không có kết nối mạng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  'Vui lòng kiểm tra kết nối Wi-Fi hoặc dữ liệu di động để tiếp tục trải nghiệm Drivio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Compact refined retry button
                OutlinedButton.icon(
                  onPressed: isChecking ? null : onRetry,
                  icon: isChecking
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.primaryColor,
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: context.primaryColor,
                        ),
                  label: Text(
                    isChecking ? 'Đang kết nối lại...' : 'Thử lại',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    side: BorderSide(
                      color: context.primaryColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: isDark
                        ? context.primaryColor.withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
