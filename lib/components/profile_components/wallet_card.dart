import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF3B2F25)
                  : const Color(0xFFFAF2EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.wallet_rounded,
              color: context.secondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ví của tôi',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '2.450.000đ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: context.isDarkMode
                  ? const Color(0xFF3B2F25)
                  : const Color(0xFFFAF2EC),
              foregroundColor: context.secondaryColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              side: BorderSide(
                color: context.isDarkMode
                    ? const Color(0xFF5A4638)
                    : const Color(0xFFF0DCD0),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Xem chi tiết',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
