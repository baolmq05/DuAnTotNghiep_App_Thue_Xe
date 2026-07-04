import 'dart:ui';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:duantotnghiep_app_thue_xe/routes/router_config.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chatbot_viewmodel.dart';

void main() {
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
        ChangeNotifierProvider(create: (context) => ConversationViewmodel()),
        ChangeNotifierProvider(create: (context) => ChatbotViewModel()),
      ],
      child: MaterialApp.router(
        // Device_Preview Package (Important)
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,

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
        routerConfig: drivioRouter,
      ),
    );
  }
}
