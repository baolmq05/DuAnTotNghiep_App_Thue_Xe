import 'package:duantotnghiep_app_thue_xe/components/setting_components/logout_button.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          "Cài đặt",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          const SizedBox(height: 16),
          const Text(
            'Cài đặt chung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Thông báo',
                  onTap: () {
                    context.push('/notification');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.language_outlined,
                  title: 'Ngôn ngữ',
                  trailing: Text(
                    'Tiếng Việt',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Giao diện tối',
                  showChevron: false,
                  showDivider: false,
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeTrackColor: AppColors.primary,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hỗ trợ & Thông tin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Trung tâm trợ giúp',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.note_alt_outlined,
                  title: 'Chính sách & quy định ',
                  onTap: () {
                    context.push('/policy');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.policy_outlined,
                  title: 'Chính sách bảo mật',
                  onTap: () {
                    context.push('/privacy-policy');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'Giới thiệu ứng dụng',
                  showDivider: false,
                  trailing: Text(
                    'Phiên bản 1.0.0',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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

  Widget _buildMenuItem({
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
                  color: AppColors.primary.withValues(alpha: 0.7),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[trailing, const SizedBox(width: 4)],
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, thickness: 1, color: AppColors.border),
        ],
      ),
    );
  }
}
