import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/utils/format_price.dart';

/// Widget hiển thị phần tiêu đề thông tin xe (Tên xe, Đánh giá, Số chuyến, Giá thuê)
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
    final int discountPct = (unitPrice > 0 && discount > 0)
        ? ((discount / unitPrice) * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tên xe - Chiếm trọn dòng trên cùng
          Text(
            car.name,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? const Color(0xFF4DD0E1) : context.primaryColor,
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
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                '• $tripsCount chuyến đi',
                style: TextStyle(
                  fontSize: 14.0,
                  color: context.textSecondary,
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
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: ' / ngày',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Nhãn giảm giá (nếu có) - Hiển thị dạng badge nổi bật, gọn gàng
              if (discountPct > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? const Color(0xFF4A1D1D) : Colors.red[50], // Nền đỏ nhạt
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: context.isDarkMode ? Colors.red[900]! : Colors.red[100]!,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        color: context.isDarkMode ? Colors.red[300]! : Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Giảm $discountPct%',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode ? Colors.red[300]! : Colors.red,
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
