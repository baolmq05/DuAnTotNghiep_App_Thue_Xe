import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';

class DarkModeSwitch extends StatelessWidget {
  final String title;
  final Function(bool) onTap;
  final bool value;
  const DarkModeSwitch({
    super.key,
    required this.title,
    required this.onTap,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode 
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dark_mode_outlined,
                  color: context.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: context.textPrimary),
                ),
              ],
            ),
            Row(
              spacing: 12,
              children: [
                Switch(
                  value: value,
                  onChanged: onTap,
                  activeColor: context.primaryColor,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
