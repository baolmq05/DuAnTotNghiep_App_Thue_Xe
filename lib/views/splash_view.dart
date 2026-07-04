import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    // Auto navigate to Home screen after 3 seconds or do auto login
    Future.delayed(const Duration(seconds: 3), () async {
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
      body: Container(
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
              const Text(
                'Đang khởi động...',
                textAlign: TextAlign.center,
                style: TextStyle(
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
    );
  }
}
