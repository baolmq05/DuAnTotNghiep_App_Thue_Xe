import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';

/// Widget hiển thị danh sách các tiện ích của xe (wifi, bản đồ, camera hành trình...) dạng lưới
/// Dành cho newbie: Sử dụng StatelessWidget và dùng GridView.builder để tải danh sách động từ model
class CarAmenitiesSection extends StatelessWidget {
  final Car_Detail car;

  const CarAmenitiesSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    // Nếu xe không có tiện ích nào, trả về Widget rỗng để không chiếm không gian
    if (car.features.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Grid hiển thị các tiện ích, chia thành 4 cột
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8, // Tỷ lệ chiều ngang / chiều dọc của mỗi tiện ích
            ),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: car.features.length,
            itemBuilder: (context, index) {
              final feature = car.features[index];
              return _buildAmenityImage(feature.featureName, feature.icon);
            },
          ),
        ],
      ),
    );
  }

  /// Hàm phụ hiển thị ảnh và tên của từng tiện ích
  Widget _buildAmenityImage(String name, String imageUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Khung hiển thị ảnh tiện ích
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(13), // Tạo màu nền mờ cho icon thêm đẹp
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            // Xử lý lỗi load ảnh tiện ích
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_outlined,
                color: AppColors.primary,
                size: 24,
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Tên tiện ích
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
