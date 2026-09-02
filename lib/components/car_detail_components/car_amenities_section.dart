import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';

/// Widget hiển thị danh sách các tiện ích của xe (wifi, bản đồ, camera hành trình...) dạng lưới
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
          Text(
            'Tiện ích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
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
              return _buildAmenityImage(context, feature.featureName, feature.icon);
            },
          ),
        ],
      ),
    );
  }

  /// Hàm phụ hiển thị ảnh và tên của từng tiện ích
  Widget _buildAmenityImage(BuildContext context, String name, String imageUrl) {
    final isDark = context.isDarkMode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Khung hiển thị ảnh tiện ích
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFF1F3F6) // Nền sáng khi Dark mode để các icon/chữ đen trên ảnh hiển thị rõ nét
                : context.primaryColor.withAlpha(15), // Tạo màu nền mờ cho icon thêm đẹp
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            // Xử lý lỗi load ảnh tiện ích
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_outlined,
                color: context.primaryColor,
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
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}
