import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/owner_profile_viewmodel.dart';

class OwnerProfileReviews extends StatelessWidget {
  final OwnerProfileViewModel viewModel;
  final bool isOwner;
  final Function(int reviewerId, bool isOwnerReview) onReviewerTap;

  const OwnerProfileReviews({
    super.key,
    required this.viewModel,
    required this.isOwner,
    required this.onReviewerTap,
  });

  @override
  Widget build(BuildContext context) {
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
                isOwner
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
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  isOwner
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
                            onReviewerTap(review.reviewerId, !isOwner);
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
                      foregroundColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
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
}
