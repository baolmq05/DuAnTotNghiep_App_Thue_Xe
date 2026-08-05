import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/utils/format_price.dart';

/// Widget hiển thị chính sách và điều khoản (Giới hạn quãng đường, phí giao xe, điều khoản khác)
class CarTermsSection extends StatelessWidget {
  final Car_Detail car;

  const CarTermsSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chính sách & Điều khoản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Các dòng thông tin điều khoản riêng biệt
          _buildTermItem(
            context,
            Icons.info_outline,
            'Giới hạn quãng đường: Tối đa ${car.usageLimit.maxDailyDistance}km/ngày, phụ trội ${formatPrice(car.usageLimit.extraDistanceFee)}đ/km.',
          ),
          _buildTermItem(
            context,
            Icons.local_shipping_outlined,
            'Giao xe tận nơi: Tối đa ${car.deliveryOption.maxDistance}km, miễn phí ${car.deliveryOption.freeDistance}km đầu, phí ${formatPrice(car.deliveryOption.feeDistance.toString())}đ/km.',
          ),
          _buildTermItem(
            context,
            Icons.description_outlined,
            'Điều khoản thuê: ${car.rentalTerms}',
          ),
        ],
      ),
    );
  }

  /// Hàm phụ tạo một dòng điều khoản có icon đi kèm
  Widget _buildTermItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
