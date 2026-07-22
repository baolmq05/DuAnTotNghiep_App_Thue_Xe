import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';

/// Widget hiển thị mô tả chi tiết của xe
/// Dành cho newbie: Sử dụng StatelessWidget, tự ẩn đi nếu không có mô tả (trả về Widget rỗng)
class CarDescriptionSection extends StatelessWidget {
  final Car_Detail car;

  const CarDescriptionSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    // Nếu mô tả trống hoặc null, trả về Widget rỗng để không bị khoảng cách thừa trên màn hình
    if (car.description == null || car.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            car.description!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5, // Tỷ lệ giãn dòng cho đoạn văn bản dài dễ đọc hơn
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
