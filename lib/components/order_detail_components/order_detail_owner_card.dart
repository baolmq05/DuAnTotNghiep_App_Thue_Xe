import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:go_router/go_router.dart';

class OrderDetailOwnerCard extends StatelessWidget {
  final TripModel trip;
  final OwnerModel owner;
  final bool isCreatingChat;
  final Function(TripModel, OwnerModel) onStartChat;
  final Function(OwnerModel) onCall;

  const OrderDetailOwnerCard({
    super.key,
    required this.trip,
    required this.owner,
    required this.isCreatingChat,
    required this.onStartChat,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    String? avatarUrl = owner.avatar;
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        !avatarUrl.startsWith('http')) {
      avatarUrl = 'http://10.0.2.2:8000/storage/$avatarUrl';
    }

    final bool isPaid = trip.status >= 2 && trip.status <= 4;

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
            'Chủ xe',
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    context.push('/owner-profile/${owner.id}?isOwner=true'),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
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
                  onTap: () =>
                      context.push('/owner-profile/${owner.id}?isOwner=true'),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star, color: context.primaryColor, size: 16),
                          const Text(
                            ' 4.9 ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(86 đánh giá)',
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
                  if (isPaid) ...[
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
                        onPressed: isCreatingChat
                            ? null
                            : () => onStartChat(trip, owner),
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.call,
                        color: context.primaryColor,
                        size: 20,
                      ),
                      onPressed: () => onCall(owner),
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
