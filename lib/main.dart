import 'package:duantotnghiep_app_thue_xe/themes/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:duantotnghiep_app_thue_xe/routes/router_config.dart';

void main() {
  runApp(
    DevicePreview(enabled: !kReleaseMode, builder: (context) => DrivioApp()),
  );
}

class DrivioApp extends StatelessWidget {
  const DrivioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Device_Preview Package (Important)
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      // Main Code
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: drivioRouter,
    );
  }
}
