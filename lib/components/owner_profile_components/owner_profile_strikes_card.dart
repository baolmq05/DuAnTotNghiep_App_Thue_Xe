import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/owner_report_summary_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class OwnerProfileStrikesCard extends StatelessWidget {
  final OwnerReportSummaryModel summary;

  const OwnerProfileStrikesCard({super.key, required this.summary});

  Color _getStrikeColor(int strikes, bool isSuspended) {
    if (isSuspended || strikes >= 3) {
      return AppColors.error;
    }
    if (strikes == 2) {
      return Colors.deepOrange;
    }
    if (strikes == 1) {
      return Colors.amber.shade800;
    }
    return AppColors.success;
  }

  String _getStrikeStatusText(int strikes, bool isSuspended) {
    if (isSuspended || strikes >= 3) {
      return 'Tài khoản đang bị đình chỉ / khóa';
    }
    if (strikes == 2) {
      return 'Cảnh báo cấp 2: Nguy cơ bị khóa nếu nhận thêm 1 Strike';
    }
    if (strikes == 1) {
      return 'Cảnh cáo cấp 1 (Có hiệu lực trong 90 ngày)';
    }
    return 'Tài khoản an toàn & uy tín cao';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final strikeColor = _getStrikeColor(
      summary.activeStrikes,
      summary.isAccountSuspended,
    );
    final statusText = _getStrikeStatusText(
      summary.activeStrikes,
      summary.isAccountSuspended,
    );

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: summary.activeStrikes > 0
              ? strikeColor.withAlpha(120)
              : context.border,
          width: summary.activeStrikes > 0 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: strikeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      summary.activeStrikes > 0
                          ? Icons.warning_amber_rounded
                          : Icons.verified_user_rounded,
                      color: strikeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tình trạng vi phạm & Strike',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Hệ thống theo dõi kỷ luật chủ xe',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Badge trạng thái tài khoản
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: summary.isAccountSuspended
                      ? AppColors.error.withAlpha(30)
                      : AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: summary.isAccountSuspended
                        ? AppColors.error
                        : AppColors.success,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: summary.isAccountSuspended
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      summary.accountStatus == 'ACTIVE'
                          ? 'Hoạt động'
                          : 'Tạm khóa',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: summary.isAccountSuspended
                            ? AppColors.error
                            : (isDark
                                  ? Colors.greenAccent
                                  : Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Strike Gauge / Progress Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Số Strike hiệu lực:',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: strikeColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${summary.activeStrikes} / 3 Strikes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: strikeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tổng lịch sử: ${summary.totalStrikes}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3-Segment Progress Bar
                Row(
                  children: List.generate(3, (index) {
                    final isFilled = index < summary.activeStrikes;
                    Color barColor;
                    if (index == 0)
                      barColor = Colors.amber.shade700;
                    else if (index == 1)
                      barColor = Colors.deepOrange;
                    else
                      barColor = AppColors.error;

                    return Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0.0),
                        decoration: BoxDecoration(
                          color: isFilled
                              ? barColor
                              : (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      summary.activeStrikes > 0
                          ? Icons.info_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 14,
                      color: strikeColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: strikeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Statistics Row: Reports breakdown
          Row(
            children: [
              _buildStatItem(
                context,
                title: 'Tổng khiếu nại',
                value: '${summary.reports.total}',
                color: context.primaryColor,
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                context,
                title: 'Đang xử lý',
                value: '${summary.reports.pending}',
                color: Colors.orange.shade700,
                icon: Icons.hourglass_top_rounded,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildStatItem(
                context,
                title: 'Đã giải quyết',
                value: '${summary.reports.resolved}',
                color: AppColors.success,
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                context,
                title: 'Từ chối',
                value: '${summary.reports.rejected}',
                color: AppColors.error,
                icon: Icons.cancel_outlined,
              ),
            ],
          ),

          // Danh sách án phạt đang có hiệu lực (Active Penalties)
          if (summary.activePenalties.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'Án phạt đang có hiệu lực (${summary.activePenalties.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...summary.activePenalties.map(
              (penalty) => _buildPenaltyItem(context, penalty, isDark),
            ),
          ],

          // Báo cáo gần đây (Recent Reports)
          if (summary.recentReports.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: context.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Báo cáo vi phạm gần đây',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...summary.recentReports.map(
              (report) => _buildRecentReportItem(context, report, isDark),
            ),
          ],

          const SizedBox(height: 12),

          // Nút tìm hiểu chính sách Strike
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showStrikePolicyModal(context),
              icon: Icon(
                Icons.help_outline_rounded,
                size: 15,
                color: context.primaryColor,
              ),
              label: Text(
                'Tìm hiểu chính sách điểm phạt & 90 ngày hiệu lực',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.primaryColor,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final isDark = context.isDarkMode;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? color.withAlpha(25) : color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40), width: 0.8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltyItem(
    BuildContext context,
    OwnerActivePenalty penalty,
    bool isDark,
  ) {
    Color badgeBgColor;
    Color badgeTextColor;
    Color containerBgColor;
    Color borderColor;

    switch (penalty.penaltyTypeCode) {
      case 2: // Khóa tài khoản
        badgeBgColor = AppColors.error.withAlpha(30);
        badgeTextColor = AppColors.error;
        containerBgColor = isDark ? const Color(0xFF2A1B1B) : const Color(0xFFFFF1F2);
        borderColor = AppColors.error.withAlpha(60);
        break;
      case 1: // Cảnh báo lần 2
        badgeBgColor = Colors.deepOrange.withAlpha(30);
        badgeTextColor = Colors.deepOrange;
        containerBgColor = isDark ? const Color(0xFF2A201B) : const Color(0xFFFFF7ED);
        borderColor = Colors.deepOrange.withAlpha(60);
        break;
      case 0: // Cảnh cáo lần 1
      default:
        badgeBgColor = Colors.amber.shade800.withAlpha(30);
        badgeTextColor = isDark ? Colors.amber.shade400 : Colors.amber.shade900;
        containerBgColor = isDark ? const Color(0xFF24221A) : const Color(0xFFFEFCE8);
        borderColor = Colors.amber.shade800.withAlpha(50);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  penalty.penaltyTypeDisplay.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
              if (penalty.displayTripCode.isNotEmpty)
                Text(
                  'Mã chuyến: ${penalty.displayTripCode}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            penalty.reason,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
              height: 1.3,
            ),
          ),
          if (penalty.endAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 12,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Hết hạn cảnh cáo vào: ${penalty.endAt}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentReportItem(
    BuildContext context,
    OwnerRecentReport report,
    bool isDark,
  ) {
    Color statusColor;
    switch (report.statusCode) {
      case 1:
        statusColor = Colors.green.shade700;
        break;
      case 2:
        statusColor = Colors.red.shade700;
        break;
      case 0:
      default:
        statusColor = Colors.orange.shade700;
        break;
    }
    final statusText = report.statusDisplay;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (report.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    report.createdAt!,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStrikePolicyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetCtx).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(sheetCtx).padding.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quy định về Strike & Xử lý vi phạm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const Divider(height: 16),
              _buildPolicyRule(
                context,
                icon: Icons.timer_outlined,
                color: Colors.blue,
                title: 'Hiệu lực 90 ngày',
                desc:
                    'Mỗi Strike (cảnh cáo) do Admin xác nhận có hiệu lực trong vòng 90 ngày kể từ ngày ban hành. Sau 90 ngày, Strike sẽ tự động hết hạn và không còn tính vào Strike hiệu lực.',
              ),
              const SizedBox(height: 12),
              _buildPolicyRule(
                context,
                icon: Icons.looks_one_rounded,
                color: Colors.amber.shade800,
                title: '1 Strike — Cảnh cáo lần đầu',
                desc:
                    'Chủ xe nhận thông báo nhắc nhở về chất lượng dịch vụ hoặc quy trình giao nhận xe. Xe vẫn hoạt động bình thường.',
              ),
              const SizedBox(height: 12),
              _buildPolicyRule(
                context,
                icon: Icons.looks_two_rounded,
                color: Colors.deepOrange,
                title: '2 Strike — Cảnh báo nghiêm trọng',
                desc:
                    'Chủ xe bị giảm mức độ ưu tiên hiển thị xe trong kết quả tìm kiếm. Nếu phát sinh thêm 1 vi phạm nữa sẽ bị khóa tài khoản.',
              ),
              const SizedBox(height: 12),
              _buildPolicyRule(
                context,
                icon: Icons.block_rounded,
                color: AppColors.error,
                title: '3 Strike — Đình chỉ tài khoản (SUSPENDED)',
                desc:
                    'Tài khoản chủ xe và toàn bộ xe đang cho thuê sẽ bị tạm dừng hoạt động trên hệ thống Drivio để Admin kiểm tra và xử lý.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyRule(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
