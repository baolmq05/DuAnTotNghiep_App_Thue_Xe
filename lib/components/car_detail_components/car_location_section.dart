import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';

/// Widget hiển thị vị trí (địa chỉ) của xe
/// Dành cho newbie: Sử dụng StatelessWidget vì chỉ hiển thị địa chỉ của xe
class CarLocationSection extends StatelessWidget {
  final Car_Detail car;

  const CarLocationSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn lề icon và text thẳng hàng từ trên xuống
        children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              car.carLocation.address,
              style: const TextStyle(
                fontSize: 14.0,
                color: AppColors.textSecondary,
                height: 1.4, // Tạo khoảng cách giãn dòng cho dễ đọc địa chỉ dài
              ),
            ),
          ),
        ],
      ),
    );
  }
}
