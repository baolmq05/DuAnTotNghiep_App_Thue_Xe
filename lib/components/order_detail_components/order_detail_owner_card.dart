import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:go_router/go_router.dart';

class OrderDetailOwnerCard extends StatelessWidget {
  final TripModel trip;
  final String cardTitle;
  final int personId;
  final String personName;
  final String? avatar;
  final double rating;
  final int reviewsCount;
  final bool isOwnerProfile;
  final bool isCreatingChat;
  final VoidCallback onStartChat;

  const OrderDetailOwnerCard({
    super.key,
    required this.trip,
    required this.cardTitle,
    required this.personId,
    required this.personName,
    this.avatar,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.isOwnerProfile,
    required this.isCreatingChat,
    required this.onStartChat,
  });

  /// Factory hiển thị thông tin Chủ xe (dành cho Khách thuê xem)
  factory OrderDetailOwnerCard.owner({
    Key? key,
    required TripModel trip,
    required OwnerModel owner,
    required bool isCreatingChat,
    required VoidCallback onStartChat,
  }) {
    return OrderDetailOwnerCard(
      key: key,
      trip: trip,
      cardTitle: 'Chủ xe',
      personId: owner.id,
      personName: owner.name,
      avatar: owner.avatar,
      rating: owner.rating,
      reviewsCount: owner.reviewsCount,
      isOwnerProfile: true,
      isCreatingChat: isCreatingChat,
      onStartChat: onStartChat,
    );
  }

  /// Factory hiển thị thông tin Khách thuê (dành cho Chủ xe xem)
  factory OrderDetailOwnerCard.renter({
    Key? key,
    required TripModel trip,
    required TripRenterInfo renter,
    required bool isCreatingChat,
    required VoidCallback onStartChat,
  }) {
    return OrderDetailOwnerCard(
      key: key,
      trip: trip,
      cardTitle: 'Khách thuê',
      personId: renter.id,
      personName: renter.name,
      avatar: renter.avatar,
      rating: renter.rating,
      reviewsCount: renter.reviewsCount,
      isOwnerProfile: false,
      isCreatingChat: isCreatingChat,
      onStartChat: onStartChat,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? avatarUrl = avatar;
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        !avatarUrl.startsWith('http')) {
      final base = (!kIsWeb && Platform.isAndroid)
          ? 'http://10.0.2.2:8000'
          : 'http://127.0.0.1:8000';
      avatarUrl = avatarUrl.startsWith('/')
          ? '$base/storage$avatarUrl'
          : '$base/storage/$avatarUrl';
    }

    final bool isPaid = trip.status >= 2 && trip.status <= 4;
    final ratingText = rating > 0 ? rating.toStringAsFixed(1) : '0.0';
    final reviewText = reviewsCount > 0
        ? '($reviewsCount đánh giá)'
        : '(Chưa có đánh giá)';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cardTitle,
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push(
                    '/owner-profile/$personId?isOwner=$isOwnerProfile'),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl)
                          : null,
                  onBackgroundImageError:
                      (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? (exception, stackTrace) {}
                          : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(
                          Icons.person,
                          color: context.textSecondary,
                          size: 28,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                      '/owner-profile/$personId?isOwner=$isOwnerProfile'),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: context.primaryColor,
                            size: 16,
                          ),
                          Text(
                            ' $ratingText ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            reviewText,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPaid)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: isCreatingChat
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.chat_bubble_outline,
                                color: context.primaryColor,
                                size: 20,
                              ),
                        onPressed: isCreatingChat ? null : onStartChat,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

