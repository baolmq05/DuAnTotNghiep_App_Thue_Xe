import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';

/// Widget hiển thị thông số kỹ thuật của xe (Số ghế, truyền động, loại nhiên liệu, tiêu hao)
/// Dành cho newbie: Sử dụng StatelessWidget và phân tách thành hàm con `_buildSpecTile` cho code gọn gàng, dễ quản lý
class CarSpecSection extends StatelessWidget {
  final Car_Detail car;

  const CarSpecSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sử dụng GridView để hiển thị 4 thông số chia đều làm 2 cột
          GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.zero,
            shrinkWrap: true, // Cho phép GridView tự co dãn theo kích thước phần tử con
            physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn riêng của GridView vì đã nằm trong ListView chính
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5, // Tỷ lệ chiều rộng / chiều cao của mỗi ô thông số
            children: [
              _buildSpecTile(
                Icons.airline_seat_recline_normal_rounded,
                'Số ghế',
                '${car.seatCount} chỗ',
              ),
              _buildSpecTile(
                Icons.settings_suggest_rounded,
                'Truyền động',
                car.transmission,
              ),
              _buildSpecTile(
                Icons.local_gas_station_rounded,
                'Nhiên liệu',
                car.fuelType,
              ),
              _buildSpecTile(
                Icons.speed_rounded,
                'Tiêu hao',
                '${car.fuelConsumption}L/100km',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Hàm phụ hiển thị từng ô thông số riêng biệt
  Widget _buildSpecTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
