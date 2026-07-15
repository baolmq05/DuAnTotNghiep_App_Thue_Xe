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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => _goBack(context),
        ),
        title: Text(
          currentIsOwner ? 'Thông tin chủ xe' : 'Hồ sơ khách thuê',
          style: const TextStyle(
            color: AppColors.textPrimary,
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
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đã xảy ra lỗi: ${viewModel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
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

                const Divider(
                  height: 24,
                  thickness: 1,
                  color: AppColors.border,
                ),

                // 2. Danh sách đánh giá
                _buildReviewsSection(context, viewModel, currentIsOwner),

                // 3. Danh sách xe (nếu là chủ xe)
                if (currentIsOwner) ...[
                  const Divider(
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
                  backgroundColor: AppColors.card,
                  backgroundImage: profile.avatar != null
                      ? NetworkImage(profile.avatar!)
                      : null,
                  child: profile.avatar == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.textSecondary,
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tham gia từ ${profile.joinDate}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
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
              color: AppColors.card,
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
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.rating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Đánh giá',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
                        const Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${profile.tripsCount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentIsOwner ? 'Chuyến đi' : 'Chuyến thuê',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
                    color: AppColors.textSecondary,
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
              separatorBuilder: (context, index) => const Divider(
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
                            backgroundColor: AppColors.card,
                            backgroundImage: review.reviewerAvatar != null
                                ? NetworkImage(review.reviewerAvatar!)
                                : null,
                            child: review.reviewerAvatar == null
                                ? const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.textSecondary,
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
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
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
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
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    label: const Text('Xem thêm đánh giá'),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
                  child: const Text(
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'Chủ xe này chưa đăng ký xe nào.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
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
