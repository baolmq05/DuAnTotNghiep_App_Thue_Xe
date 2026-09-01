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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Icon container with soft circular glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF2C1A1D)
                      : const Color(0xFFFEE2E2),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF7F1D1D)
                        : const Color(0xFFFECACA),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 54,
                    color: isDark
                        ? const Color(0xFFF87171)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'Mất kết nối Internet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle / Description
              Text(
                'Ứng dụng Drivio yêu cầu kết nối mạng để tải dữ liệu.\nVui lòng kiểm tra lại đường truyền Wi-Fi hoặc dữ liệu di động (4G/5G) của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),

              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isChecking ? null : onRetry,
                  icon: isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                  label: Text(
                    isChecking ? 'Đang kiểm tra kết nối...' : 'Thử kết nối lại',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    disabledBackgroundColor:
                        context.primaryColor.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Footer Note
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Cần trợ giúp khẩn cấp? Hotline: 1900 9217',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
