import 'package:duantotnghiep_app_thue_xe/components/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị trực tiếp branch đang hoạt động
      body: navigationShell,
      bottomNavigationBar: BottomNavigation(
        selectedIndex: navigationShell.currentIndex,
        onTabChange: (index) {
          // Điều hướng sang branch tương ứng
          navigationShell.goBranch(
            index,
            // Nếu click lại vào tab hiện tại -> quay về màn hình đầu của tab đó
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
