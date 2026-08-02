import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class SupportInfoGrid extends StatelessWidget {
  final Function(String title) onInfoItemTap;

  const SupportInfoGrid({
    super.key,
    required this.onInfoItemTap,
  });

  Widget _buildInfoItem(BuildContext context, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onInfoItemTap(title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.35,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildInfoItem(context, Icons.business_rounded, 'Thông tin công ty'),
        _buildInfoItem(context, Icons.gavel_rounded, 'Chính sách và quy định'),
        _buildInfoItem(context, Icons.star_outline_rounded, 'Đánh giá Drivio'),
        _buildInfoItem(context, Icons.facebook_rounded, 'Facebook Fanpage'),
        _buildInfoItem(context, Icons.help_center_rounded, 'Hỏi và trả lời'),
        _buildInfoItem(context, Icons.assignment_rounded, 'Quy chế hoạt động'),
        _buildInfoItem(context, Icons.lock_rounded, 'Bảo mật thông tin'),
        _buildInfoItem(context, Icons.handshake_rounded, 'Giải quyết tranh chấp'),
      ],
    );
  }
}
