import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/components/profile_components/profile_menu_item.dart';

class ServicesCard extends StatelessWidget {
  final UserModel? user;

  const ServicesCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.favorite_border_rounded,
            title: 'Xe yêu thích',
            onTap: () {
              context.push('/favorite');
            },
          ),
          ProfileMenuItem(
            icon: Icons.badge_outlined,
            title: 'Giấy phép lái xe',
            trailing: _buildLicenseBadge(context, user),
            onTap: () {
              context.push('/driver-license');
            },
          ),
          ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Đặt lại mật khẩu',
            onTap: () {
              context.push('/change-password');
            },
          ),
          ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Trung tâm hỗ trợ',
            showDivider: false,
            onTap: () {
              context.push('/support');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseBadge(BuildContext context, UserModel? user) {
    final license = user?.drivingLicense;
    if (license == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.warningSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Chưa xác thực',
          style: TextStyle(
            color: context.warning,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (license.status == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.successSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Đã xác thực',
          style: TextStyle(
            color: context.success,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.warningSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Chờ duyệt',
        style: TextStyle(
          color: context.warning,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
