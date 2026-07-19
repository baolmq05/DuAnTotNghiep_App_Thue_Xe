import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  // Biến này cho biết đang kiểm tra kết nối hay không, dùng để disable nút thử lại.
  bool _isChecking = false;
  // Biến này quyết định có hiển thị dialog cảnh báo không có mạng hay không.
  bool _showNoInternet = false;

  @override
  void initState() {
    super.initState();
    // Tạm ngưng hoạt động check kết nối bằng cách giữ code trong khối comment.
    // _checkConnection();
    _proceedToApp();
  }

  /*
  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    final hasInternet = await ConnectivityHelper.hasInternetConnection();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _showNoInternet = !hasInternet;
    });

    if (hasInternet) {
      _proceedToApp();
    } else {
      AppToast.show(
        context,
        message: 'Không có kết nối Internet. Vui lòng kiểm tra lại!',
        type: ToastType.error,
      );
    }
  }
  */

  // Hàm chuyển sang màn hình tiếp theo sau khi kiểm tra kết nối thành công.
  void _proceedToApp() {
    // Chờ 1.5 giây để người dùng thấy splash trước khi điều hướng.
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = await authProvider.tryAutoLogin();

      if (mounted) {
        if (isLoggedIn) {
          context.go('/home');
        } else {
          context.go('/slide1');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Splash Background & Content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF144E5B), Color(0xFF092832)],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50.0),

                  // Custom Team Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 90.0,
                      fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation<double>(0.9),
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'Drivio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(76),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Subtitles/Slogans
                  const Text(
                    'Thuê xe tự lái nhanh chóng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  const Text(
                    '• An toàn • Minh bạch',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(),

                  // Custom Illustration (SUV, Scooter & Road)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.asset(
                        'assets/splash_illustration.png',
                        height: 260.0,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 260.0,
                          ); // Empty fallback space
                        },
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Loading Progress
                  Center(
                    child: SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        backgroundColor: Colors.white.withAlpha(38),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Starting up text
                  Text(
                    _isChecking
                        ? 'Đang kiểm tra kết nối...'
                        : 'Đang khởi động...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ),

          // Internet connection alert overlay
          if (_showNoInternet)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(160),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Center(
                    child: PopScope(
                      canPop: false, // Prevent back navigation
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(64),
                              blurRadius: 15.0,
                              spreadRadius: 1.0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFFFEE3CE,
                                ), // AppColors.accentSurface
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wifi_off_rounded,
                                color: Color(0xFFA77E52), // AppColors.secondary
                                size: 48.0,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            const Text(
                              'Không có kết nối Internet',
                              style: TextStyle(
                                color: Color(
                                  0xFF1F2937,
                                ), // AppColors.textPrimary
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12.0),
                            const Text(
                              'Vui lòng kết nối Internet để tiếp tục sử dụng ứng dụng Drivio.',
                              style: TextStyle(
                                color: Color(
                                  0xFF6B7280,
                                ), // AppColors.textSecondary
                                fontSize: 14.0,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24.0),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      SystemNavigator.pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ), // AppColors.border
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Đóng app',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isChecking ? null : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFF286874,
                                      ), // AppColors.primary
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                    ),
                                    child: _isChecking
                                        ? const SizedBox(
                                            height: 18.0,
                                            width: 18.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Thử lại',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
