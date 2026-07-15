import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';

class OwnerProfile {
  final int id;
  final String name;
  final String? avatar;
  final String? phone;
  final double rating;
  final int tripsCount;
  final String joinDate;
  final List<OwnerReview> reviews;
  final List<Car> cars;

  OwnerProfile({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
    required this.rating,
    required this.tripsCount,
    required this.joinDate,
    required this.reviews,
    required this.cars,
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    var reviewList = json['reviews'] as List? ?? [];
    List<OwnerReview> parsedReviews = reviewList.where((r) => r != null).map((r) => OwnerReview.fromJson(r as Map<String, dynamic>)).toList();

    var carList = json['cars'] as List? ?? [];
    List<Car> parsedCars = carList.where((c) => c != null).map((c) => Car.fromJson(c as Map<String, dynamic>)).toList();

    return OwnerProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      phone: json['phone']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      tripsCount: json['trips_count'] is int
          ? json['trips_count']
          : int.tryParse(json['trips_count']?.toString() ?? '') ?? 0,
      joinDate: json['join_date']?.toString() ?? json['joinDate']?.toString() ?? '',
      reviews: parsedReviews,
      cars: parsedCars,
    );
  }
}

class OwnerReview {
  final int id;
  final int reviewerId;
  final String reviewerName;
  final String? reviewerAvatar;
  final double rating;
  final String comment;
  final String createdAt;

  OwnerReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory OwnerReview.fromJson(Map<String, dynamic> json) {
    return OwnerReview(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      reviewerId: json['reviewer_id'] is int 
          ? json['reviewer_id'] 
          : int.tryParse(json['reviewer_id']?.toString() ?? '') ?? 0,
      reviewerName: json['reviewer_name']?.toString() ?? '',
      reviewerAvatar: json['reviewer_avatar']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
