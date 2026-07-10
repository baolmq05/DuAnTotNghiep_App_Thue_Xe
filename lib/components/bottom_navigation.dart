import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final conversationViewModel = context.watch<ConversationViewmodel>();
    final int messageCount = conversationViewModel.conversations.fold(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        child: GNav(
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,

          gap: 6,
          iconSize: 22,
          duration: const Duration(milliseconds: 300),
          color: Colors.grey.shade500, // Màu icon khi chưa chọn (nhạt dịu mắt)
          activeColor: AppColors.primary, // Màu icon/chữ khi được chọn
          tabBackgroundColor: AppColors.primary.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

          tabs: [
            GButton(
              icon: selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              text: 'Trang chủ',
            ),
            GButton(
              icon: selectedIndex == 1
                  ? Icons.calendar_today
                  : Icons.calendar_today_outlined,
              text: 'Đơn thuê',
            ),
            GButton(
              icon: selectedIndex == 2
                  ? Icons.message
                  : Icons.message_outlined,
              text: 'Tin nhắn',
              leading: Badge(
                isLabelVisible: messageCount > 0,
                label: Text(
                  '$messageCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red,
                offset: const Offset(6, -4),
                child: Icon(
                  selectedIndex == 2 ? Icons.message : Icons.message_outlined,
                  size: 22,
                  color: selectedIndex == 2
                      ? AppColors.primary
                      : Colors.grey.shade500,
                ),
              ),
            ),
            GButton(
              icon: selectedIndex == 3 ? Icons.person : Icons.person_outline,
              text: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
