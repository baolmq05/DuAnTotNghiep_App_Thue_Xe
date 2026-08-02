import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
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
                if (trailing != null) ...[trailing!, const SizedBox(width: 4)],
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
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
