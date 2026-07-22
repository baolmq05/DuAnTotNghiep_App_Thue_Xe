import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/utils/format_price.dart';
import 'package:go_router/go_router.dart';

/// Widget hiển thị thanh đặt xe ở dưới cùng màn hình (Tổng tiền ước tính và nút ĐẶT XE NGAY)
/// Dành cho newbie: Sử dụng StatelessWidget, bọc trong SafeArea để tránh bị lẹm vào phần tai thỏ/điều hướng của hệ điều hành
class CarBottomBar extends StatelessWidget {
  final Car_Detail car;

  const CarBottomBar({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    // Tính toán giá thực tế sau khi giảm
    final double unitPrice = double.tryParse(car.unitPrice) ?? 0;
    final double discount = double.tryParse(car.discountValue) ?? 0;
    final double finalPrice = unitPrice - discount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05), // Tạo bóng đổ nhẹ phía trên thanh đặt xe
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Phần hiển thị giá tiền
            Column(
              mainAxisSize: MainAxisSize.min, // Giới hạn kích thước cột tối thiểu để tránh tràn dòng
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng cộng (ước tính)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(
                        text: ' / ngày',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Nút "ĐẶT XE NGAY" chuyển hướng tới trang Booking
            ElevatedButton(
              onPressed: () {
                context.push('/booking-car/${car.id}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ĐẶT XE NGAY',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
