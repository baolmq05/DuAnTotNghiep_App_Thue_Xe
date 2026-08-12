import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class OrderDetailTimeline extends StatelessWidget {
  final TripModel trip;
  final Function(TripModel) onCancel;
  final bool isOwner;

  const OrderDetailTimeline({
    super.key,
    required this.trip,
    required this.onCancel,
    this.isOwner = false,
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

  String _getStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Chờ duyệt';
      case 1:
        return 'Chờ thanh toán';
      case 2:
        return 'Đã xác nhận';
      case 3:
        return 'Đang diễn ra';
      case 4:
        return 'Đã hoàn thành';
      case 5:
        return 'Người dùng hủy';
      case 6:
        return 'Chủ xe hủy';
      case 7:
        return 'Chờ gia hạn';
      case 8:
        return 'Chờ trả xe';
      default:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = trip.status;
    final isCancelled = status == 5 || status == 6;

    final isStep1 = status >= 0;
    final isStep2 = status >= 1 && !isCancelled;
    final isStep3 = status >= 2 && !isCancelled;
    final isStep4 = status >= 3 && !isCancelled;
    final isStep5 = status == 4;

    final bool canCancel = isOwner
        ? (status == 1 || status == 2)
        : (status >= 0 && status < 3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trạng thái đơn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? Colors.red.shade100
                      : (status == 4
                          ? Colors.green.shade100
                          : Colors.orange.shade100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCancelled
                        ? Colors.red.shade700
                        : (status == 4
                            ? Colors.green.shade700
                            : Colors.orange.shade800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Chờ duyệt',
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
                  title: 'Chờ TT',
                  time: isStep2 ? 'Chờ thanh toán' : '--',
                  isDone: isStep2,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.check_circle_outline,
                  title: 'Xác nhận',
                  time: isStep3 ? 'Đã xác nhận' : '--',
                  isDone: isStep3,
                  showLeftLine: true,
                  showRightLine: true,
                ),
              ),
              Expanded(
                child: _buildTimelineStep(
                  context,
                  icon: Icons.directions_car,
                  title: 'Đang thuê',
                  time: isStep4
                      ? (status == 7
                          ? 'Chờ gia hạn'
                          : status == 8
                              ? 'Chờ trả xe'
                              : _formatDateTime(trip.startAt))
                      : '--',
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
                  time: isStep5 ? 'Đã hoàn thành' : '--',
                  isDone: isStep5,
                  showLeftLine: true,
                  showRightLine: false,
                ),
              ),
            ],
          ),
          if (isCancelled) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 16),
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
