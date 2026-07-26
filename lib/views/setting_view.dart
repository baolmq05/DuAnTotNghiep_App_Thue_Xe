import 'package:duantotnghiep_app_thue_xe/components/setting_components/logout_button.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "Cài đặt",
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          const SizedBox(height: 16),
          Text(
            'Cài đặt chung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: context.isDarkMode 
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Thông báo',
                  onTap: () {
                    context.push('/notification');
                  },
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildMenuItem(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Giao diện tối',
                      showChevron: false,
                      showDivider: false,
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                        activeTrackColor: context.primaryColor,
                      ),
                      onTap: () {
                        themeProvider.toggleTheme(!themeProvider.isDarkMode);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hỗ trợ & Thông tin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: context.isDarkMode 
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Trung tâm trợ giúp',
                  onTap: () {
                    context.push('/support');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.note_alt_outlined,
                  title: 'Chính sách & quy định ',
                  onTap: () {
                    context.push('/policy');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.policy_outlined,
                  title: 'Chính sách bảo mật',
                  onTap: () {
                    context.push('/privacy-policy');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Giới thiệu ứng dụng',
                  showDivider: false,
                  trailing: Text(
                    'Phiên bản 1.0.0',
                    style: TextStyle(color: context.textSecondary, fontSize: 13),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          LogoutButton(
            onTap: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    bool showDivider = true,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: context.primaryColor.withValues(alpha: 0.7),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[trailing, const SizedBox(width: 4)],
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                    size: 20,
                  ),
              ],
            ),
          ),
          if (showDivider)
            Divider(height: 1, thickness: 1, color: context.border),
        ],
      ),
    );
  }
}
