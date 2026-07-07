import 'dart:core';

class DeliveryOption {
  final int id;
  final int maxDistance;
  final int feeDistance;
  final int freeDistance;
  final int status;
  final String createdAt;
  final String updatedAt;

  DeliveryOption({
    required this.id,
    required this.maxDistance,
    required this.feeDistance,
    required this.freeDistance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryOption.fromJson(Map<String, dynamic> json) {
    return DeliveryOption(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      maxDistance: json['max_distance'] is int
          ? json['max_distance']
          : int.tryParse(json['max_distance']?.toString() ?? '') ?? 0,
      feeDistance: json['fee_distance'] is int
          ? json['fee_distance']
          : int.tryParse(json['fee_distance']?.toString() ?? '') ?? 0,
      freeDistance: json['free_distance'] is int
          ? json['free_distance']
          : int.tryParse(json['free_distance']?.toString() ?? '') ?? 0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
