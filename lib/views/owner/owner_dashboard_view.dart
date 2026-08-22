import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_order_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/models/owner_report_summary_model.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerOrderViewModel>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final orderVM = context.watch<OwnerOrderViewModel>();
    final pendingCount = orderVM.getCountForTab(1); // Chờ duyệt

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Quản lý Chủ xe',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<OwnerOrderViewModel>().fetchDashboardData(),
        color: context.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card xin chào chủ xe
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primaryColor,
                      context.primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage:
                          (user?.avatar != null &&
                              user!.avatar!.startsWith('http'))
                          ? NetworkImage(user.avatar!)
                          : const AssetImage(
                                  'lib/assets/images/default-avatar.jpg',
                                )
                                as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào, ${user?.name ?? 'Chủ xe'}! 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Bảng điều khiển & Thống kê hoạt động xe',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Khối chỉ số nhanh (Quick Stats)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Đơn chờ duyệt',
                      value: '$pendingCount',
                      icon: Icons.hourglass_top_rounded,
                      color: Colors.orange,
                      onTap: () => context.push('/owner-orders'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Tổng đơn hàng',
                      value: '${orderVM.allTrips.length}',
                      icon: Icons.assignment_outlined,
                      color: context.primaryColor,
                      onTap: () => context.push('/owner-orders'),
                    ),
                  ),
                ],
              ),

              // Banner tóm tắt Strike & Tình trạng tài khoản
              if (orderVM.reportSummary != null) ...[
                const SizedBox(height: 16),
                _buildStrikeSummaryBanner(context, orderVM.reportSummary!),
              ],

              const SizedBox(height: 20),

              Text(
                'Danh mục quản lý',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Danh sách các chức năng chính của chủ xe
              _buildFeatureTile(
                context,
                icon: Icons.local_shipping_outlined,
                iconColor: context.primaryColor,
                title: 'Quản lý đơn cho thuê xe',
                subtitle: pendingCount > 0
                    ? 'Có $pendingCount đơn đang chờ bạn phê duyệt'
                    : 'Xem và quản lý tất cả đơn hàng cho thuê',
                badgeCount: pendingCount,
                onTap: () => context.push('/owner-orders'),
              ),
              const SizedBox(height: 10),
              _buildFeatureTile(
                context,
                icon: Icons.directions_car_filled_outlined,
                iconColor: Colors.teal,
                title: 'Quản lý danh sách xe',
                subtitle: 'Xem, chỉnh sửa trạng thái và thông tin xe của bạn',
                onTap: () => context.push('/owner-vehicles'),
              ),
              const SizedBox(height: 10),
              _buildFeatureTile(
                context,
                icon: Icons.add_circle_outline_rounded,
                iconColor: Colors.indigo,
                title: 'Đăng ký xe mới',
                subtitle: 'Đăng thêm xe để cho thuê và tăng thu nhập',
                onTap: () => context.push('/register-car'),
              ),
              const SizedBox(height: 10),
              _buildFeatureTile(
                context,
                icon: Icons.bar_chart_rounded,
                iconColor: Colors.purple,
                title: 'Báo cáo & Thống kê doanh thu',
                subtitle: 'Chức năng thống kê chi tiết đang được phát triển',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tính năng Báo cáo & Thống kê đang được cập nhật!',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      if (badgeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrikeSummaryBanner(
    BuildContext context,
    OwnerReportSummaryModel summary,
  ) {
    Color strikeColor;
    if (summary.isAccountSuspended || summary.activeStrikes >= 3) {
      strikeColor = AppColors.error;
    } else if (summary.activeStrikes == 2) {
      strikeColor = Colors.deepOrange;
    } else if (summary.activeStrikes == 1) {
      strikeColor = Colors.amber.shade800;
    } else {
      strikeColor = AppColors.success;
    }

    return InkWell(
      onTap: () => context.push('/owner-strikes'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: summary.activeStrikes > 0
                ? strikeColor.withAlpha(120)
                : context.border,
            width: summary.activeStrikes > 0 ? 1.2 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Điểm phạt (Strike): ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        '${summary.activeStrikes}/3',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: strikeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary.isAccountSuspended
                        ? 'Tài khoản đang bị tạm khóa'
                        : (summary.activeStrikes > 0
                              ? 'Có ${summary.activeStrikes} cảnh cáo có hiệu lực 90 ngày'
                              : 'Tài khoản hoạt động an toàn & uy tín'),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: context.primaryColor.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: context.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
