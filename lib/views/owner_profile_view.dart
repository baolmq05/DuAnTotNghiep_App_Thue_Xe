import 'package:duantotnghiep_app_thue_xe/components/home_components/home_car_card.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/owner_profile_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OwnerProfileView extends StatefulWidget {
  final int ownerId;
  final int? fromCarId;
  final bool isOwner;

  const OwnerProfileView({
    super.key,
    required this.ownerId,
    this.fromCarId,
    this.isOwner = true, // mặc định chế độ xem chủ xe
  });

  @override
  State<OwnerProfileView> createState() => _OwnerProfileViewState();
}

class _OwnerProfileViewState extends State<OwnerProfileView> {
  @override
  void initState() {
    super.initState();
    // Gọi ViewModel để tải dữ liệu chủ xe sau khi dựng khung hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerProfileViewModel>(
        context,
        listen: false,
      ).fetchOwnerProfile(ownerId: widget.ownerId, isOwner: widget.isOwner);
    });
  }

  // Tự động chạy lại API khi bấm chuyển ID hoặc vai trò (isOwner)
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
    // Kiểm tra xem trong lịch sử router còn trang nào để quay lại không
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
                  SizedBox(height: 16),
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
                      icon: Icon(Icons.refresh_rounded),
                      label: Text('Thử lại'),
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
                // 1. Header cá nhân chủ xe
                _buildOwnerHeader(profile, currentIsOwner),

                Divider(
                  height: 24,
                  thickness: 1,
                  color: AppColors.border,
                ),

                // 2. Danh sách đánh giá
                _buildReviewsSection(context, viewModel, currentIsOwner),

                // 3. Danh sách xe (nếu là chủ xe)
                if (currentIsOwner) ...[
                  Divider(
                    height: 24,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  _buildCarsSection(context, profile),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== WIDGETS BUILDERS ====================

  Widget _buildOwnerHeader(OwnerProfile profile, bool currentIsOwner) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: context.cardColor,
                  backgroundImage: profile.avatar != null
                      ? NetworkImage(profile.avatar!)
                      : null,
                  child: profile.avatar == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: context.textSecondary,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Tên và ngày tham gia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tham gia từ ${profile.joinDate}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chỉ số Thống kê (Sao & Chuyến)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Số sao
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.rating.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đánh giá',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Đường sọc đứng phân chia
                Container(height: 32, width: 1, color: AppColors.border),
                // Số chuyến
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${profile.tripsCount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentIsOwner ? 'Chuyến đi' : 'Chuyến thuê',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    OwnerProfileViewModel viewModel,
    bool currentIsOwner
  ) {
    final totalReviews = viewModel.reviews.length;
    final displayList = viewModel.reviews
        .take(viewModel.visibleReviewsCount)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentIsOwner
                    ? 'Đánh giá từ khách hàng ($totalReviews)'
                    : 'Đánh giá từ chủ xe ($totalReviews)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (viewModel.reviews.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  currentIsOwner
                      ? 'Chủ xe này chưa có đánh giá nào'
                      : 'Người thuê này chưa có đánh giá nào',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else ...[
            // Danh sách các đánh giá
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              separatorBuilder: (context, index) => Divider(
                height: 20,
                thickness: 0.5,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final review = displayList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(
                              '/owner-profile/${review.reviewerId}?isOwner=${!currentIsOwner}',
                            );
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: context.cardColor,
                            backgroundImage: review.reviewerAvatar != null
                                ? NetworkImage(review.reviewerAvatar!)
                                : null,
                            child: review.reviewerAvatar == null
                                ? Icon(
                                    Icons.person,
                                    size: 18,
                                    color: context.textSecondary,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.reviewerName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (starIdx) {
                                      return Icon(
                                        Icons.star_rounded,
                                        color: starIdx < review.rating.floor()
                                            ? Colors.amber
                                            : Colors.grey.shade300,
                                        size: 14,
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    review.createdAt,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                );
              },
            ),
            // Nút Xem thêm
            if (viewModel.hasMoreReviews)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      viewModel.loadMoreReviews();
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    label: Text('Xem thêm đánh giá'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCarsSection(BuildContext context, OwnerProfile profile) {
    final cars = profile.cars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề & Nút Xem tất cả
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách xe (${cars.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (cars.isNotEmpty)
                TextButton(
                  onPressed: () => _showAllCarsBottomSheet(context, cars, profile.name),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (cars.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'Chủ xe này chưa đăng ký xe nào.',
                style: TextStyle(color: context.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          // Danh sách xe dạng cuộn ngang
          SizedBox(
            height:
                425, // Tăng chiều cao để đủ hiển thị HomeCarCard mà không bị tràn (Overflow)
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: HomeCarCard(
                    width: 290,
                    car: car,
                    onTap: () {
                      context.push('/car_detail/${car.id}');
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Hiển thị danh sách toàn bộ xe trong Bottom Sheet
  void _showAllCarsBottomSheet(BuildContext context, List<Car> cars, String ownerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Thanh gạch nhỏ định vị kéo thả
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tất cả xe của $ownerName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 8.0,
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: HomeCarCard(
                          width: double.infinity,
                          car: car,
                          onTap: () {
                            Navigator.pop(context); // Đóng bottom sheet trước
                            context.push('/car_detail/${car.id}');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String viewModelName(BuildContext context) {
    final profile = Provider.of<OwnerProfileViewModel>(
      context,
      listen: false,
    ).ownerProfile;
    return profile?.name ?? '';
  }
}
