import 'package:duantotnghiep_app_thue_xe/components/setting_components/dark_mode_switch.dart';
import 'package:duantotnghiep_app_thue_xe/components/setting_components/logout_button.dart';
import 'package:duantotnghiep_app_thue_xe/components/setting_components/setting_tile.dart';
import 'package:flutter/material.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Cài đặt",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 15, right: 15),
        children: [
          SizedBox(height: 24),
          Text(
            'CÀI ĐẶT CHUNG',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12),
          SettingTile(
            title: 'Thông báo',
            icon: Icon(Icons.notifications_none_rounded),
            onTap: () {},
          ),
          SizedBox(height: 6),
          SettingTile(
            title: 'Ngôn ngữ',
            subtitle: 'Tiếng Việt',
            icon: Icon(Icons.language_outlined),
            onTap: () {},
          ),
          SizedBox(height: 6),
          DarkModeSwitch(
            title: 'Giao diện tối',
            value: false,
            onTap: (value) {},
          ),
          SizedBox(height: 32),
          Text(
            'HỖ TRỢ & THÔNG TIN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12),
          SettingTile(
            title: 'Trung tâm trợ giúp',
            icon: Icon(Icons.help_outline),
            onTap: () {},
          ),
          SizedBox(height: 6),
          SettingTile(
            title: 'Điều khoản sử dụng',
            icon: Icon(Icons.note_alt_outlined),
            onTap: () {},
          ),
          SizedBox(height: 6),
          SettingTile(
            title: 'Chính sách bảo mật',
            icon: Icon(Icons.policy_outlined),
            onTap: () {},
          ),
          SizedBox(height: 6),
          SettingTile(
            title: 'Giới thiệu ứng dụng',
            subtitle: 'Phiên bản 1.0.0',
            icon: Icon(Icons.info_outline),
            onTap: () {},
          ),
          SizedBox(height: 48),
          LogoutButton(onTap: () {}),
        ],
      ),
    );
  }
}
