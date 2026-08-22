import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/owner_profile_components/owner_profile_header.dart';
import 'package:duantotnghiep_app_thue_xe/components/owner_profile_components/owner_profile_reviews.dart';
import 'package:duantotnghiep_app_thue_xe/components/owner_profile_components/owner_profile_cars.dart';

class OwnerProfileView extends StatefulWidget {
  final int ownerId;
  final int? fromCarId;
  final bool isOwner;

  const OwnerProfileView({
    super.key,
    required this.ownerId,
    this.fromCarId,
    this.isOwner = true,
  });

  @override
  State<OwnerProfileView> createState() => _OwnerProfileViewState();
}

class _OwnerProfileViewState extends State<OwnerProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerProfileViewModel>(
        context,
        listen: false,
      ).fetchOwnerProfile(ownerId: widget.ownerId, isOwner: widget.isOwner);
    });
  }

  @override
  void didUpdateWidget(covariant OwnerProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId || oldWidget.isOwner != widget.isOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<OwnerProfileViewModel>(context, listen: false)
            .fetchOwnerProfile(ownerId: widget.ownerId, isOwner: widget.isOwner);
      });
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop(); 
    } else if (widget.fromCarId != null) {
      context.go('/car_detail/${widget.fromCarId}');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => _goBack(context),
        ),
        title: Text(
          'Hồ sơ người dùng',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<OwnerProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.ownerProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải thông tin hồ sơ...',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null && viewModel.ownerProfile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: context.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đã xảy ra lỗi: ${viewModel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        viewModel.fetchOwnerProfile(
                          ownerId: widget.ownerId,
                          isOwner: widget.isOwner,
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = viewModel.ownerProfile;
          if (profile == null) {
            return Center(
              child: Text(
                'Không tìm thấy thông tin hồ sơ',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            );
          }

          final isOwnerTab = viewModel.currentTab == 0;

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchOwnerProfile(
                ownerId: widget.ownerId,
                isOwner: isOwnerTab,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Selector 2 Tab vai trò: Chủ xe / Người thuê
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          // Tab 1: Chủ xe
                          Expanded(
                            child: GestureDetector(
                              onTap: () => viewModel.switchTab(0, targetId: widget.ownerId),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isOwnerTab
                                      ? (isDark ? context.cardColor : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isOwnerTab
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_car_rounded,
                                      size: 18,
                                      color: isOwnerTab
                                          ? context.primaryColor
                                          : context.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Vai trò Chủ xe',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isOwnerTab
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isOwnerTab
                                            ? (isDark ? Colors.white : context.primaryColor)
                                            : context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Tab 2: Người thuê
                          Expanded(
                            child: GestureDetector(
                              onTap: () => viewModel.switchTab(1, targetId: widget.ownerId),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isOwnerTab
                                      ? (isDark ? context.cardColor : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !isOwnerTab
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      size: 18,
                                      color: !isOwnerTab
                                          ? context.primaryColor
                                          : context.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Vai trò Người thuê',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: !isOwnerTab
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: !isOwnerTab
                                            ? (isDark ? Colors.white : context.primaryColor)
                                            : context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Header Hồ sơ người dùng
                  OwnerProfileHeader(profile: profile, isOwner: isOwnerTab),

                  Divider(
                    height: 24,
                    thickness: 1,
                    color: context.border,
                  ),

                  // 3. Đánh giá từ đối tác
                  OwnerProfileReviews(
                    viewModel: viewModel,
                    isOwner: isOwnerTab,
                    onReviewerTap: (reviewerId, isOwnerReview) {
                      context.push(
                        '/owner-profile/$reviewerId?isOwner=$isOwnerReview',
                      );
                    },
                  ),

                  // 4. Danh sách xe (Chỉ hiển thị khi đang xem Tab Chủ xe)
                  if (isOwnerTab) ...[
                    Divider(
                      height: 24,
                      thickness: 1,
                      color: context.border,
                    ),
                    OwnerProfileCars(
                      profile: profile,
                      onCarTap: (car) {
                        context.push('/car_detail/${car.id}');
                      },
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
