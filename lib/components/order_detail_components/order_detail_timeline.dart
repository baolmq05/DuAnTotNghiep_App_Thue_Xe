import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class OrderDetailTimeline extends StatelessWidget {
  final TripModel trip;
  final Function(TripModel) onCancel;

  const OrderDetailTimeline({
    super.key,
    required this.trip,
    required this.onCancel,
  });

  String _formatDateTime(DateTime date) {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${pad(date.hour)}:${pad(date.minute)}';
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required bool isDone,
    required bool showLeftLine,
    required bool showRightLine,
  }) {
    final Color color = isDone ? context.primaryColor : Colors.grey.shade300;

    return Column(
      children: [
        SizedBox(
          height: 28,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: showLeftLine ? color : Colors.transparent,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: showRightLine ? color : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 30,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStep1 = trip.status >= 0;
    final isStep2 = trip.status >= 1;
    final isStep3 = trip.status >= 2;
    final isStep4 = trip.status >= 3;
    final isStep5 = trip.status == 4;

    final bool canCancel = trip.status >= 0 && trip.status < 3;

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
            'Trạng thái đơn',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Đăng ký thuê',
                  time: isStep1 ? _formatDateTime(trip.startAt) : '--',
                  isDone: isStep1,
                  showLeftLine: false,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Đặt cọc',
                  time: isStep2 ? 'Đã cọc' : '--',
                  isDone: isStep2,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.check,
                  title: 'Xác nhận',
                  time: isStep3 ? 'Thành công' : '--',
                  isDone: isStep3,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.directions_car,
                  title: 'Nhận xe',
                  time: isStep4 ? _formatDateTime(trip.startAt) : '--',
                  isDone: isStep4,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.assignment_turned_in,
                  title: 'Hoàn tất',
                  time: isStep5 ? 'Đã xong' : '--',
                  isDone: isStep5,
                  showLeftLine: true,
                  showRightLine: false,
                ),
              ),
            ],
          ),
          if (canCancel) ...[
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onCancel(trip),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Hủy chuyến đi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
