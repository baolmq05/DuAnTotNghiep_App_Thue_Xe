import 'dart:core';

class UsageLimit {
  final int id;
  final int maxDailyDistance;
  final String extraDistanceFee;
  final int status;
  final String createdAt;
  final String updatedAt;

  UsageLimit({
    required this.id,
    required this.maxDailyDistance,
    required this.extraDistanceFee,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsageLimit.fromJson(Map<String, dynamic> json) {
    return UsageLimit(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      maxDailyDistance: json['max_daily_distance'] is int
          ? json['max_daily_distance']
          : int.tryParse(json['max_daily_distance']?.toString() ?? '') ?? 0,
      extraDistanceFee: json['extra_distance_fee']?.toString() ?? '0',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
