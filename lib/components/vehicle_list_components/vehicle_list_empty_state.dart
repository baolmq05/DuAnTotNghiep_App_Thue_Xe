import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class VehicleListEmptyState extends StatelessWidget {
  final VoidCallback onClearFilters;

  const VehicleListEmptyState({
    super.key,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? const Color(0xFF1F3D45)
                    : const Color(0xFFE9F3F4),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 42,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy xe phù hợp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử đổi địa điểm hoặc từ khóa tìm kiếm để xem thêm xe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onClearFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primaryColor,
                side: BorderSide(color: context.primaryColor),
              ),
              child: const Text('Xem tất cả xe'),
            ),
          ],
        ),
      ),
    );
  }
}
