import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:intl/intl.dart';

class BookingRentalTimeCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectPickupDate;
  final VoidCallback onSelectPickupTime;
  final VoidCallback onSelectReturnDate;
  final VoidCallback onSelectReturnTime;
  final List<BoxShadow>? shadow;

  const BookingRentalTimeCard({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onSelectPickupDate,
    required this.onSelectPickupTime,
    required this.onSelectReturnDate,
    required this.onSelectReturnTime,
    this.shadow,
  });

  Widget _buildSubInputBox(BuildContext context, String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
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
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Thời gian thuê',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Nhận xe',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSubInputBox(
                  context,
                  startDate != null
                      ? DateFormat('dd/MM/yyyy').format(startDate!)
                      : 'Chọn ngày',
                  Icons.calendar_today_rounded,
                  onSelectPickupDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildSubInputBox(
                  context,
                  startDate != null
                      ? DateFormat('HH:mm').format(startDate!)
                      : 'Chọn giờ',
                  Icons.access_time_rounded,
                  onSelectPickupTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Trả xe',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSubInputBox(
                  context,
                  endDate != null
                      ? DateFormat('dd/MM/yyyy').format(endDate!)
                      : 'Chọn ngày',
                  Icons.calendar_today_rounded,
                  onSelectReturnDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildSubInputBox(
                  context,
                  endDate != null
                      ? DateFormat('HH:mm').format(endDate!)
                      : 'Chọn giờ',
                  Icons.access_time_rounded,
                  onSelectReturnTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
