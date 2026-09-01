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

  @override
  Widget build(BuildContext context) {
    final status = trip.status;
    final isCancelled = status == 5 || status == 6;

    // Determine current active step index (0 to 4)
    int currentStepIndex = 0;
    if (isCancelled) {
      currentStepIndex = -1;
    } else if (status == 4) {
      currentStepIndex = 4; // Hoàn tất
    } else if (status == 3 || status == 7 || status == 8) {
      currentStepIndex = 3; // Đang thuê
    } else if (status == 2) {
      currentStepIndex = 2; // Đã xác nhận / Đã cọc
    } else if (status == 1) {
      currentStepIndex = 1; // Chờ đặt cọc
    } else {
      currentStepIndex = 0; // Chờ duyệt
    }

    final bool canCancel = isOwner
        ? (status == 1 || status == 2)
        : (status >= 0 && status < 3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tiến trình đơn thuê',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: context.textPrimary,
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: trip.getStatusBackgroundColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trip.getStatusDisplay(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: trip.getStatusTextColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Responsive 5-Step Stepper
          LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              const int stepCount = 5;
              final double nodeSize = totalWidth < 340 ? 22.0 : 26.0;
              final double iconSize = totalWidth < 340 ? 12.0 : 14.0;

              final steps = [
                {'title': 'Chờ duyệt', 'icon': Icons.assignment_outlined},
                {'title': 'Đặt cọc', 'icon': Icons.payment_rounded},
                {'title': 'Xác nhận', 'icon': Icons.verified_outlined},
                {'title': 'Đang đi', 'icon': Icons.directions_car_rounded},
                {'title': 'Hoàn tất', 'icon': Icons.task_alt_rounded},
              ];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(stepCount, (stepIdx) {
                  final isCompleted =
                      !isCancelled && stepIdx < currentStepIndex;
                  final isCurrent =
                      !isCancelled && stepIdx == currentStepIndex;
                  final isDoneOrCurrent =
                      !isCancelled && stepIdx <= currentStepIndex;

                  final bool showLeftLine = stepIdx > 0;
                  final bool isLeftLineActive =
                      !isCancelled && stepIdx <= currentStepIndex;

                  final bool showRightLine = stepIdx < stepCount - 1;
                  final bool isRightLineActive =
                      !isCancelled && stepIdx < currentStepIndex;

                  final Color activeLineColor = context.primaryColor;
                  final Color inactiveLineColor = context.isDarkMode
                      ? const Color(0xFF333333)
                      : const Color(0xFFE2E8F0);

                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row with [Left Line] [Node Circle] [Right Line] -> Guarantees Node is in the exact horizontal center
                        SizedBox(
                          height: nodeSize + 6,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 2.5,
                                  color: showLeftLine
                                      ? (isLeftLineActive
                                          ? activeLineColor
                                          : inactiveLineColor)
                                      : Colors.transparent,
                                ),
                              ),
                              Container(
                                width: nodeSize,
                                height: nodeSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isCompleted || isCurrent)
                                      ? context.primaryColor
                                      : (context.isDarkMode
                                          ? const Color(0xFF2A2A2A)
                                          : const Color(0xFFF1F5F9)),
                                  border: isCurrent
                                      ? Border.all(
                                          color: context.primaryColor
                                              .withValues(alpha: 0.3),
                                          width: totalWidth < 340 ? 2 : 3,
                                        )
                                      : Border.all(
                                          color: (isCompleted || isCurrent)
                                              ? context.primaryColor
                                              : context.border,
                                          width: 1,
                                        ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_rounded
                                        : steps[stepIdx]['icon'] as IconData,
                                    size: iconSize,
                                    color: (isCompleted || isCurrent)
                                        ? Colors.white
                                        : context.textSecondary
                                            .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2.5,
                                  color: showRightLine
                                      ? (isRightLineActive
                                          ? activeLineColor
                                          : inactiveLineColor)
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Label text (Guaranteed to be aligned with the node above)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              steps[stepIdx]['title'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: totalWidth < 340 ? 10 : 11.5,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : (isDoneOrCurrent
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                                color: isCurrent
                                    ? context.primaryColor
                                    : (isDoneOrCurrent
                                        ? context.textPrimary
                                        : context.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),

          // Contextual Active Step Status Card
          _buildCurrentStatusCard(context, status, isCancelled),

          // Action Button: Hủy chuyến đi (if permitted)
          if (canCancel) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onCancel(trip),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.error,
                  side: BorderSide(
                    color: context.error.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  backgroundColor: context.errorSurface,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  Icons.cancel_outlined,
                  size: 17,
                  color: context.error,
                ),
                label: Text(
                  'Hủy chuyến đi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: context.error,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Contextual informative card about the current progress
  Widget _buildCurrentStatusCard(
    BuildContext context,
    int status,
    bool isCancelled,
  ) {
    if (isCancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.errorSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cancel_rounded, color: context.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status == 5
                    ? 'Khách hàng đã thực hiện hủy chuyến thuê này.'
                    : 'Chủ xe đã hủy yêu cầu chuyến thuê này.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: context.error,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    String message;
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (status) {
      case 0: // Chờ duyệt
        icon = Icons.hourglass_top_rounded;
        iconColor = context.warning;
        bgColor = context.warningSurface;
        message = isOwner
            ? 'Khách hàng đang chờ bạn duyệt đơn thuê xe này.'
            : 'Yêu cầu thuê đã được gửi đến chủ xe. Chủ xe sẽ phản hồi sớm.';
        break;
      case 1: // Chờ thanh toán
        icon = Icons.payment_rounded;
        iconColor = context.primaryColor;
        bgColor = context.infoSurface;
        message = isOwner
            ? 'Bạn đã duyệt đơn. Đang chờ khách hàng thanh toán tiền đặt cọc 30%.'
            : 'Chủ xe đã duyệt đơn! Vui lòng thanh toán cọc 30% để đảm bảo giữ xe.';
        break;
      case 2: // Đã xác nhận / Đã cọc
        icon = Icons.verified_rounded;
        iconColor = const Color(0xFF0284C7);
        bgColor = context.isDarkMode
            ? const Color(0xFF0C3B5E)
            : const Color(0xFFF0F9FF);
        message =
            'Đơn thuê đã đặt cọc thành công. Chuẩn bị bàn giao và nhận xe theo lịch hẹn.';
        break;
      case 3: // Đang di chuyển
        icon = Icons.directions_car_rounded;
        iconColor = context.primaryColor;
        bgColor = context.infoSurface;
        message = 'Xe đang trong hành trình thuê. Chúc bạn có chuyến đi an toàn!';
        break;
      case 7: // Chờ gia hạn
        icon = Icons.update_rounded;
        iconColor = const Color(0xFF9333EA);
        bgColor = context.isDarkMode
            ? const Color(0xFF3B0764)
            : const Color(0xFFFAF5FF);
        message = isOwner
            ? 'Khách hàng đã gửi yêu cầu gia hạn thêm thời gian thuê xe.'
            : 'Yêu cầu gia hạn thêm chuyến đi của bạn đang được xử lý.';
        break;
      case 8: // Chờ trả xe
        icon = Icons.assignment_return_rounded;
        iconColor = const Color(0xFFD97706);
        bgColor = context.isDarkMode
            ? const Color(0xFF451A03)
            : const Color(0xFFFEF3C7);
        message =
            'Đến giờ hoàn tất chuyến đi. Vui lòng kiểm tra xe và tiến hành bàn giao.';
        break;
      case 4: // Hoàn tất
        icon = Icons.check_circle_rounded;
        iconColor = context.success;
        bgColor = context.successSurface;
        message =
            'Chuyến đi đã hoàn tất thành công. Cảm ơn bạn đã đồng hành cùng Drivio!';
        break;
      default:
        icon = Icons.info_outline_rounded;
        iconColor = context.textSecondary;
        bgColor = context.cardColor;
        message = trip.getStatusDisplay();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: context.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
