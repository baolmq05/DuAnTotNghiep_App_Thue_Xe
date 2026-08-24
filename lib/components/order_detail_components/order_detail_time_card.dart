import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class OrderDetailTimeCard extends StatelessWidget {
  final TripModel trip;

  const OrderDetailTimeCard({
    super.key,
    required this.trip,
  });

  String _formatDate(DateTime date) {
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    String pad(int v) => v.toString().padLeft(2, '0');
    final weekdayStr = weekdays[date.weekday % 7];
    return '$weekdayStr, ${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(date.hour)}:${pad(date.minute)}';
  }

  int _calculateDays(DateTime start, DateTime end) {
    final diffMinutes = end.difference(start).inMinutes;
    final days = (diffMinutes / 1440).ceil();
    return days <= 0 ? 1 : days;
  }

  @override
  Widget build(BuildContext context) {
    DateTime effectiveEndAt = trip.endAt;
    if (trip.latestExtension != null &&
        trip.latestExtension!.status == 3 &&
        trip.latestExtension!.endDate != null) {
      final parsed = DateTime.tryParse(trip.latestExtension!.endDate!);
      if (parsed != null) {
        effectiveEndAt = parsed;
      }
    }
    final isExtended = trip.latestExtension != null &&
        trip.latestExtension!.status == 3 &&
        trip.latestExtension!.endDate != null;

    final startCity =
        (trip.deliveryAddress != null &&
            trip.deliveryAddress!.trim().isNotEmpty)
        ? trip.deliveryAddress!
        : (trip.car?.carLocation?.address ??
              trip.car?.carLocation?.city ??
              'TP. Hồ Chí Minh');
    final endCity =
        (trip.car?.carLocation?.address ??
        trip.car?.carLocation?.city ??
        'TP. Hồ Chí Minh');
    final rentalDays = _calculateDays(trip.startAt, effectiveEndAt);

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
            'Thời gian & Địa điểm',
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: context.primaryColor,
                  ),
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey.shade300,
                  ),
                  const Icon(
                    Icons.circle,
                    size: 12,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhận xe',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDateTime(trip.startAt)} • ${_formatDate(trip.startAt)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      startCity,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          'Trả xe',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (isExtended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade300, width: 0.8),
                            ),
                            child: Text(
                              'Đã gia hạn',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDateTime(effectiveEndAt)} • ${_formatDate(effectiveEndAt)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExtended ? context.primaryColor : context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      endCity,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thời gian thuê',
                style: TextStyle(color: context.textSecondary),
              ),
              Text(
                '$rentalDays ngày',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
