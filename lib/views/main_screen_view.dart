import 'package:duantotnghiep_app_thue_xe/components/bottom_navigation.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/notification_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().startNotificationWatcher();
      context.read<ConversationViewmodel>().fetchConversations(showLoading: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi người dùng mở lại app từ chạy ngầm / bật sáng màn hình
      context.read<NotificationViewModel>().checkNewNotificationsNow();
      context.read<ConversationViewmodel>().fetchConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị trực tiếp branch đang hoạt động
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigation(
        selectedIndex: widget.navigationShell.currentIndex,
        onTabChange: (index) {
          // Điều hướng sang branch tương ứng
          widget.navigationShell.goBranch(
            index,
            // Nếu click lại vào tab hiện tại -> quay về màn hình đầu của tab đó
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
