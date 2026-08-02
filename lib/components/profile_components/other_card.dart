import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/components/profile_components/profile_menu_item.dart';

class OtherCard extends StatelessWidget {
  const OtherCard({super.key});

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
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            showDivider: false,
            onTap: () {
              context.push('/setting');
            },
          ),
        ],
      ),
    );
  }
}
