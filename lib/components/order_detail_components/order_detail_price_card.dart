import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class OrderDetailPriceCard extends StatelessWidget {
  final TripModel trip;

  const OrderDetailPriceCard({
    super.key,
    required this.trip,
  });

  String _formatPrice(double price) {
    String priceStr = price.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = priceStr.replaceAllMapped(
      reg,
      (Match match) => '${match[1]}.',
    );
    return '$resultđ';
  }

  int _calculateDays(DateTime start, DateTime end) {
    final diffMinutes = end.difference(start).inMinutes;
    final days = (diffMinutes / 1440).ceil();
    return days <= 0 ? 1 : days;
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? context.textPrimary : context.textSecondary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount
                ? AppColors.success
                : (isTotal ? AppColors.primary : context.textPrimary),
            fontWeight: isTotal || isDiscount ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = trip.car;
    if (car == null) return const SizedBox.shrink();

    final rentalDays = _calculateDays(trip.startAt, trip.endAt);
    final double netTotal = (trip.cost - trip.discountAmount) < 0
        ? 0.0
        : (trip.cost - trip.discountAmount);

    double actualPaid = trip.paidAmount;
    if (actualPaid == 0 &&
        trip.status >= 2 &&
        trip.status != 5 &&
        trip.status != 6) {
      actualPaid = netTotal * 0.4;
    }

    final double unpaidAmount = (netTotal - actualPaid) < 0
        ? 0.0
        : (netTotal - actualPaid);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết giá',
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(
            context,
            'Đơn giá thuê',
            '${_formatPrice(car.unitPrice)}/ngày',
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            context,
            'Tiền thuê xe ($rentalDays ngày)',
            _formatPrice(car.unitPrice * rentalDays),
          ),
          const SizedBox(height: 12),
          if (trip.deliveryFee > 0)
            _buildPriceRow(
              context,
              'Phí giao nhận xe',
              _formatPrice(trip.deliveryFee),
            ),
          if (trip.discountAmount > 0)
            _buildPriceRow(
              context,
              'Khuyến mãi',
              '-${_formatPrice(trip.discountAmount)}',
              isDiscount: true,
            ),
          if (trip.latestExtension != null &&
              trip.latestExtension!.status == 3) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              context,
              'Phí gia hạn xe (${trip.latestExtension!.extendedDays} ngày)',
              _formatPrice(trip.latestExtension!.extensionAmount),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          _buildPriceRow(
            context,
            'Tổng cộng',
            _formatPrice(netTotal),
            isTotal: true,
          ),
          if (trip.status >= 2 && trip.status != 5 && trip.status != 6) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(),
            ),
            _buildPriceRow(
              context,
              'Đã đặt cọc (40%)',
              _formatPrice(actualPaid),
            ),
            const SizedBox(height: 12),
            _buildPriceRow(
              context,
              'Số tiền còn lại thanh toán khi nhận xe',
              _formatPrice(unpaidAmount),
            ),
          ],
        ],
      ),
    );
  }
}
