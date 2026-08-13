import 'dart:ui';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_theme.dart';
import 'package:duantotnghiep_app_thue_xe/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:duantotnghiep_app_thue_xe/routes/router_config.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chatbot_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/home_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/order_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/order_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/notification_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chat_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/address_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/car_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/policy_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/favorite_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/wallet_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:duantotnghiep_app_thue_xe/firebase_options.dart';
import 'package:duantotnghiep_app_thue_xe/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase và FCM Service
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final fcmService = FcmService();
    await fcmService.initialize();

    // Điều hướng khi người dùng nhấn vào thông báo đẩy
    fcmService.onNotificationClick = (Map<String, dynamic> data) {
      debugPrint('XỬ LÝ ĐIỀU HƯỚNG KHI CLICK THÔNG BÁO: $data');
      final type = (data['type'] ?? data['notification_type'] ?? data['screen'] ?? '').toString().toLowerCase();

      final conversationId = data['conversation_id'] ?? data['conversationId'];
      final tripId = data['trip_id'] ?? data['order_id'] ?? data['tripId'] ?? data['orderId'] ?? data['id'];
      final isOwner = data['is_owner']?.toString() == 'true' || type == 'owner_order';

      // 1. Nhắn tin / Chat
      if (type == 'chat' || type == 'message' || conversationId != null) {
        if (conversationId != null && conversationId.toString().isNotEmpty) {
          drivioRouter.push('/chat/${conversationId.toString()}');
        } else {
          drivioRouter.push('/messages');
        }
        return;
      }

      // 2. Chuyến xe / Đặt xe / Duyệt xe / Trạng thái đơn thuê
      if (type == 'trip' ||
          type == 'order' ||
          type == 'booking' ||
          type == 'trip_update' ||
          type == 'rental' ||
          type == 'owner_order' ||
          tripId != null) {
        if (isOwner) {
          drivioRouter.push('/owner-orders');
        } else if (tripId != null && int.tryParse(tripId.toString()) != null) {
          drivioRouter.push('/order-detail/${tripId.toString()}');
        } else {
          drivioRouter.push('/orders');
        }
        return;
      }

      // 3. Mặc định: Thông báo hệ thống
      drivioRouter.push('/notification');
    };
  } catch (e) {
    debugPrint('Lỗi khởi tạo Firebase trong main: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const DrivioApp(),
      ),
    ),
  );
}

class DrivioApp extends StatelessWidget {
  const DrivioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ConversationViewmodel()),
        ChangeNotifierProvider(create: (context) => ChatbotViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => OrderViewModel()),
        ChangeNotifierProvider(create: (context) => OrderDetailViewModel()),
        ChangeNotifierProvider(create: (context) => NotificationViewModel()),
        ChangeNotifierProvider(create: (context) => ChatDetailViewModel()),
        ChangeNotifierProvider(create: (context) => AddressViewModel()),
        ChangeNotifierProvider(create: (context) => CarDetailViewmodel()),
        ChangeNotifierProvider(create: (context) => PolicyViewModel()),
        ChangeNotifierProvider(create: (context) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (context) => WalletViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            // Device_Preview Package (Important)
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
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

            // Main Code
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: drivioRouter,
          );
        },
      ),
    );
  }
}
