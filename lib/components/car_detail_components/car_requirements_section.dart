import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

/// Widget hiển thị các giấy tờ yêu cầu khi thuê xe (Bằng lái xe, CCCD...)
class CarRequirementsSection extends StatelessWidget {
  const CarRequirementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giấy tờ thuê xe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Hiển thị 2 loại giấy tờ xếp ngang nhau bằng Row và Expanded
          Row(
            children: [
              Expanded(
                child: _buildRequirementCard(
                  context,
                  Icons.card_membership_outlined,
                  'Bằng lái xe',
                  'Yêu cầu GPLX hạng B1 hoặc B2 trở lên',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRequirementCard(
                  context,
                  Icons.assignment_ind_outlined,
                  'CCCD gắn chíp',
                  'Hoặc Hộ chiếu bản gốc (đối chiếu khi nhận xe)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Hàm phụ tạo thẻ hiển thị thông tin từng yêu cầu giấy tờ
  Widget _buildRequirementCard(BuildContext context, IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 110,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: context.textSecondary,
                height: 1.3,
              ),
              overflow: TextOverflow.fade, // Cắt chữ hoặc mờ dần nếu văn bản quá dài so với khung
            ),
          ),
        ],
      ),
    );
  }
}
