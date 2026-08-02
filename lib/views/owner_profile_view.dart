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
    final bool currentIsOwner = widget.isOwner;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => _goBack(context),
        ),
        title: Text(
          currentIsOwner ? 'Thông tin chủ xe' : 'Hồ sơ khách thuê',
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
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    currentIsOwner
                        ? 'Đang tải thông tin chủ xe...'
                        : 'Đang tải hồ sơ khách thuê...',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.error,
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
                        backgroundColor: AppColors.primary,
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
                currentIsOwner
                    ? 'Không tìm thấy thông tin chủ xe'
                    : 'Không tìm thấy hồ sơ khách thuê',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OwnerProfileHeader(profile: profile, isOwner: currentIsOwner),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: AppColors.border,
                ),
                OwnerProfileReviews(
                  viewModel: viewModel,
                  isOwner: currentIsOwner,
                  onReviewerTap: (reviewerId, isOwnerReview) {
                    context.push(
                      '/owner-profile/$reviewerId?isOwner=$isOwnerReview',
                    );
                  },
                ),
                if (currentIsOwner) ...[
                  Divider(
                    height: 24,
                    thickness: 1,
                    color: AppColors.border,
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
          );
        },
      ),
    );
  }
}
