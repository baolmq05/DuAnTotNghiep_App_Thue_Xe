import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:intl/intl.dart';

class BookingPriceBreakdownCard extends StatelessWidget {
  final CarModel car;
  final int totalDays;
  final double baseRentalPrice;
  final bool isDeliveryToLocation;
  final double calculatedDeliveryFee;
  final double carDiscountTotal;
  final double promoDiscount;
  final double totalAmount;
  final double totalDiscountAmount;
  final List<BoxShadow>? shadow;

  const BookingPriceBreakdownCard({
    super.key,
    required this.car,
    required this.totalDays,
    required this.baseRentalPrice,
    required this.isDeliveryToLocation,
    required this.calculatedDeliveryFee,
    required this.carDiscountTotal,
    required this.promoDiscount,
    required this.totalAmount,
    required this.totalDiscountAmount,
    this.shadow,
  });

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
    bool isFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: context.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount || isFree
                ? AppColors.success
                : context.textPrimary,
            fontSize: 14,
            fontWeight: isDiscount || isFree
                ? FontWeight.bold
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bảng tính giá chi tiết',
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(
            context,
            'Đơn giá thuê',
            '${_formatCurrency(car.unitPrice)}/ngày',
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            context,
            'Tổng tiền thuê ($totalDays ngày)',
            _formatCurrency(baseRentalPrice),
          ),
          const SizedBox(height: 12),
          if (isDeliveryToLocation)
            _buildPriceRow(
              context,
              'Phí giao xe tận nơi',
              calculatedDeliveryFee == 0
                  ? 'Miễn phí'
                  : _formatCurrency(calculatedDeliveryFee),
              isFree: calculatedDeliveryFee == 0,
            ),
          if (car.discountValue > 0)
            _buildPriceRow(
              context,
              'Giảm giá từ chủ xe',
              '-${_formatCurrency(carDiscountTotal)}',
              isDiscount: true,
            ),
          if (promoDiscount > 0)
            _buildPriceRow(
              context,
              'Mã voucher giảm thêm',
              '-${_formatCurrency(promoDiscount)}',
              isDiscount: true,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(totalAmount),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (totalDiscountAmount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tiết kiệm ${_formatCurrency(totalDiscountAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
