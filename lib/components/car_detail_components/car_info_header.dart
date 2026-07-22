import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/utils/format_price.dart';

/// Widget hiển thị phần tiêu đề thông tin xe (Tên xe, Đánh giá, Số chuyến, Giá thuê)
/// Dành cho newbie: Sử dụng StatelessWidget vì đây là widget tĩnh chỉ nhận dữ liệu và hiển thị, không lưu trạng thái
class CarInfoHeader extends StatelessWidget {
  final Car_Detail car;

  const CarInfoHeader({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    // Xử lý điểm đánh giá trung bình và số chuyến đi từ model
    final rating = car.reviewsAvgRating?.toStringAsFixed(1) ?? '0';
    final tripsCount = car.tripsCount;

    // Tính toán giá thực tế sau khi giảm
    final double unitPrice = double.tryParse(car.unitPrice) ?? 0;
    final double discount = double.tryParse(car.discountValue) ?? 0;
    final double finalPrice = unitPrice - discount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tên xe - Chiếm trọn dòng trên cùng, thoải mái xuống dòng nếu tên quá dài
          Text(
            car.name,
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),

          // 2. Hàng đánh giá (Rating) & Số chuyến đi
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4.0),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                '• $tripsCount chuyến đi',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 3. Phần hiển thị giá tiền & Giảm giá (nếu có)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Giá xe / ngày
              Text.rich(
                TextSpan(
                  children: [
                    // Nếu có giảm giá, hiển thị giá gốc gạch ngang trước
                    if (discount > 0) ...[
                      TextSpan(
                        text: formatPriceWithUnit(car.unitPrice),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: ' '),
                    ],
                    TextSpan(
                      text: formatPriceWithUnit(finalPrice.toString()),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(
                      text: ' / ngày',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Nhãn giảm giá (nếu có) - Hiển thị dạng badge nổi bật, gọn gàng
              if ((double.tryParse(car.discountValue) ?? 0) > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.red[50], // Nền đỏ nhạt
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: Colors.red[100]!, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer_outlined, color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Giảm ${formatPrice(car.discountValue)}đ',
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
