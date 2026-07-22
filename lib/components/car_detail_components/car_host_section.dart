import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:go_router/go_router.dart';

/// Widget hiển thị thông tin chủ xe (Avatar, tên, sao đánh giá và chuyến đi)
/// Dành cho newbie: Sử dụng StatelessWidget, khi nhấn vào avatar hoặc tên sẽ chuyển hướng qua trang profile chủ xe
class CarHostSection extends StatelessWidget {
  final Car_Detail car;

  const CarHostSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final owner = car.owner;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar chủ xe (bọc trong GestureDetector để bắt sự kiện nhấn)
                GestureDetector(
                  onTap: () => context.pushReplacement(
                    '/owner-profile/${owner.id}?isOwner=true',
                    extra: {'fromCarId': car.id},
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: owner.avatar != null
                        ? NetworkImage(owner.avatar!)
                        : null,
                    child: owner.avatar == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Tên chủ xe
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.pushReplacement(
                      '/owner-profile/${owner.id}?isOwner=true',
                      extra: {'fromCarId': car.id},
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              owner.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
                // Điểm đánh giá trung bình & Số chuyến đi của chủ xe
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${car.reviewsAvgRating?.toStringAsFixed(1) ?? '0'} (${car.tripsCount})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
