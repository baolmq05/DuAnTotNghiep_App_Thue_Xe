import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/utils/format_price.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/car_detail_viewmodel.dart';
import 'package:go_router/go_router.dart';

/// Widget hiển thị thanh đặt xe ở dưới cùng màn hình (Tổng tiền ước tính và nút ĐẶT XE NGAY)
/// Dành cho newbie: Sử dụng StatelessWidget, bọc trong SafeArea để tránh bị lẹm vào phần tai thỏ/điều hướng của hệ điều hành
class CarBottomBar extends StatelessWidget {
  final Car_Detail car;
  final bool hasBooked;

  const CarBottomBar({
    super.key,
    required this.car,
    this.hasBooked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán giá thực tế sau khi giảm
    final double unitPrice = double.tryParse(car.unitPrice) ?? 0;
    final double discount = double.tryParse(car.discountValue) ?? 0;
    final double finalPrice = unitPrice - discount;

    final currentUser = context.watch<AuthProvider>().user;
    final bool isOwner = currentUser != null && currentUser.id == car.userId;
    final bool isButtonDisabled = hasBooked || isOwner;

    String buttonText = 'ĐẶT XE NGAY';
    if (hasBooked) {
      buttonText = 'ĐÃ ĐẶT XE';
    } else if (isOwner) {
      buttonText = 'XE CỦA BẠN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
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
                Text(
                  'Tổng cộng (ước tính)',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
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
                          style: TextStyle(
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: ' / ngày',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Nút "ĐẶT XE NGAY" chuyển hướng tới trang Booking
            ElevatedButton(
              onPressed: isButtonDisabled
                  ? null
                  : () async {
                      await context.push('/booking-car/${car.id}');
                      if (context.mounted) {
                        context
                            .read<CarDetailViewmodel>()
                            .fetchCarDetail(id: car.id);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isButtonDisabled ? Colors.grey.shade400 : AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade400,
                disabledForegroundColor: Colors.white,
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
              child: Text(
                buttonText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

