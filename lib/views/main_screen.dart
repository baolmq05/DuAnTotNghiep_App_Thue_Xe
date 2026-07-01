import 'package:duantotnghiep_app_thue_xe/components/bottom_navigation.dart';
import 'package:duantotnghiep_app_thue_xe/views/home_view.dart';
import 'package:duantotnghiep_app_thue_xe/views/setting_view.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Danh sách 4 trang chính tương ứng với 4 nút dưới Bottom Navigation
  final List<Widget> _pages = [
    const HomeView(),
    const Scaffold(body: Center(child: Text("Màn hình Đơn thuê"))),
    const Scaffold(body: Center(child: Text("Màn hình Tin nhắn"))),
    const Scaffold(body: Center(child: Text("Màn hình Cá nhân"))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
