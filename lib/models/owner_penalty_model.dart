import 'user_model.dart';
import 'trip_model.dart';

class OwnerPenaltyModel {
  final int id;
  final int ownerId;
  final int? tripId;
  final double amount;
  final String reason;
  final int status; // 0: Unpaid/Chưa thanh toán, 1: Paid/Đã thanh toán, 2: Waived/Được miễn
  final String? statusText;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional nested models
  final UserModel? owner;
  final TripModel? trip;

  OwnerPenaltyModel({
    required this.id,
    required this.ownerId,
    this.tripId,
    required this.amount,
    required this.reason,
    required this.status,
    this.statusText,
    this.createdAt,
    this.updatedAt,
    this.owner,
    this.trip,
  });

  factory OwnerPenaltyModel.fromJson(Map<String, dynamic> json) {
    return OwnerPenaltyModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      ownerId: json['owner_id'] is int ? json['owner_id'] as int : int.tryParse(json['owner_id']?.toString() ?? '') ?? 0,
      tripId: json['trip_id'] is int ? json['trip_id'] as int : int.tryParse(json['trip_id']?.toString() ?? ''),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      reason: json['reason']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      statusText: json['status_text']?.toString() ?? json['status_name']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      owner: json['owner'] != null && json['owner'] is Map<String, dynamic>
          ? UserModel.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      trip: json['trip'] != null && json['trip'] is Map<String, dynamic>
          ? TripModel.fromJson(json['trip'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'trip_id': tripId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'status_text': statusText,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (owner != null) 'owner': owner!.toJson(),
    };
  }

  OwnerPenaltyModel copyWith({
    int? id,
    int? ownerId,
    int? tripId,
    double? amount,
    String? reason,
    int? status,
    String? statusText,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? owner,
    TripModel? trip,
  }) {
    return OwnerPenaltyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      owner: owner ?? this.owner,
      trip: trip ?? this.trip,
    );
  }

  String getStatusDisplay() {
    if (statusText != null && statusText!.isNotEmpty) {
      return statusText!;
    }
    switch (status) {
      case 0:
        return 'Chưa thanh toán';
      case 1:
        return 'Đã thanh toán';
      case 2:
        return 'Được miễn';
      default:
        return 'Không xác định';
    }
  }
}
