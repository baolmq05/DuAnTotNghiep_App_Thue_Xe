import 'dart:ui';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_theme.dart';
import 'package:duantotnghiep_app_thue_xe/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:duantotnghiep_app_thue_xe/routes/router_config.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chatbot_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/home_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/order_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/order_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/notification_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/address_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/policy_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/favorite_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/wallet_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/network_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/widgets/no_internet_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:duantotnghiep_app_thue_xe/firebase_options.dart';
import 'package:duantotnghiep_app_thue_xe/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and FCM Service
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final fcmService = FcmService();
    await fcmService.initialize();

    // Handle navigation when user taps on a push notification
    fcmService.onNotificationClick = (Map<String, dynamic> data) {
      debugPrint('Handling notification click navigation: $data');
      final type =
          (data['type'] ?? data['notification_type'] ?? data['screen'] ?? '')
              .toString()
              .toLowerCase();
      final conversationId = data['conversation_id'] ?? data['conversationId'];

      // 1. Chat/Message notification -> Navigate to Chat screen
      if (type == 'chat' ||
          type == 'message' ||
          (conversationId != null && conversationId.toString().isNotEmpty)) {
        if (conversationId != null && conversationId.toString().isNotEmpty) {
          drivioRouter.push('/chat/${conversationId.toString()}');
        } else {
          drivioRouter.push('/messages');
        }
        return;
      }

      // 2. All other notifications (car status, approvals, admin, promotions, orders, etc.)
      // -> Navigate directly to the Notification List screen
      drivioRouter.push('/notification');
    };
  } catch (e) {
    debugPrint('Error initializing Firebase in main: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const DrivioApp(),
    ),
  );
}

class DrivioApp extends StatelessWidget {
  const DrivioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NetworkViewModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ConversationViewmodel()),
        ChangeNotifierProvider(create: (context) => ChatbotViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => OrderViewModel()),
        ChangeNotifierProvider(create: (context) => OrderDetailViewModel()),
        ChangeNotifierProvider(create: (context) => NotificationViewModel()),
        ChangeNotifierProvider(create: (context) => AddressViewModel()),
        ChangeNotifierProvider(create: (context) => PolicyViewModel()),
        ChangeNotifierProvider(create: (context) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (context) => WalletViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],

            // Enable drag-to-scroll with mouse on Web
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
                PointerDeviceKind.trackpad,
              },
            ),

            // Main Configuration
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: drivioRouter,
            builder: (context, routerChild) {
              final networkVM = context.watch<NetworkViewModel>();
              if (!networkVM.isOnline) {
                return NoInternetScreen(
                  onRetry: () => networkVM.checkConnection(),
                  isChecking: networkVM.isChecking,
                );
              }
              return routerChild ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
