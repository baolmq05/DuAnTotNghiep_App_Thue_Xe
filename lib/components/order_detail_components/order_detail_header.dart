import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class OrderDetailHeader extends StatelessWidget {
  final TripModel trip;

  const OrderDetailHeader({
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

  String _formatDate(DateTime date) {
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    String pad(int v) => v.toString().padLeft(2, '0');
    final weekdayStr = weekdays[date.weekday % 7];
    return '$weekdayStr, ${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    switch (trip.status) {
      case 0:
        statusBgColor = Colors.orange;
        break;
      case 1:
        statusBgColor = Colors.blue;
        break;
      case 2:
      case 3:
      case 4:
      case 8:
        statusBgColor = AppColors.success;
        break;
      case 7:
        statusBgColor = Colors.indigo;
        break;
      default:
        statusBgColor = AppColors.error;
    }

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

    final double ratio = netTotal > 0 ? (actualPaid / netTotal) : 0.0;
    final bool isDepositPaid =
        trip.status >= 2 && trip.status != 5 && trip.status != 6;
    final bool isFullPaid = isDepositPaid && ratio >= 0.9;

    String depositStatusText;
    if (trip.status == 5 || trip.status == 6) {
      depositStatusText = 'Chuyến đi đã hủy';
    } else if (trip.status == 7) {
      depositStatusText = 'Đang chờ duyệt gia hạn';
    } else if (trip.status == 8) {
      depositStatusText = 'Chờ chủ xe nhận xe';
    } else if (!isDepositPaid) {
      depositStatusText = trip.status == 0
          ? 'Chờ chủ xe duyệt'
          : 'Chờ thanh toán cọc';
    } else if (isFullPaid) {
      depositStatusText = 'Đã thanh toán 100% (${_formatPrice(actualPaid)})';
    } else {
      depositStatusText = 'Đã đặt cọc 40% (${_formatPrice(actualPaid)})';
    }

    return Container(
      color: context.primaryColor,
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              trip.getStatusDisplay(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.displayCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đặt ngày ${_formatDate(trip.startAt)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatPrice(netTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      depositStatusText,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
