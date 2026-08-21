import 'user_model.dart';
import 'trip_model.dart';

class ReportModel {
  final int id;
  final int userId;
  final int? reportedUserId;
  final int? carId;
  final int? tripId;
  final String title;
  final String description;
  final int status; // 0: Pending/Chờ xử lý, 1: Resolved/Đã xử lý, 2: Rejected/Đã từ chối
  final String? statusText;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional nested models
  final UserModel? user;
  final UserModel? reportedUser;
  final CarModel? car;
  final TripModel? trip;

  ReportModel({
    required this.id,
    required this.userId,
    this.reportedUserId,
    this.carId,
    this.tripId,
    required this.title,
    required this.description,
    required this.status,
    this.statusText,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.reportedUser,
    this.car,
    this.trip,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      reportedUserId: json['reported_user_id'] is int ? json['reported_user_id'] as int : int.tryParse(json['reported_user_id']?.toString() ?? ''),
      carId: json['car_id'] is int ? json['car_id'] as int : int.tryParse(json['car_id']?.toString() ?? ''),
      tripId: json['trip_id'] is int ? json['trip_id'] as int : int.tryParse(json['trip_id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      statusText: json['status_text']?.toString() ?? json['status_name']?.toString(),
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      reportedUser: json['reported_user'] != null && json['reported_user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['reported_user'] as Map<String, dynamic>)
          : null,
      car: json['car'] != null && json['car'] is Map<String, dynamic>
          ? CarModel.fromJson(json['car'] as Map<String, dynamic>)
          : null,
      trip: json['trip'] != null && json['trip'] is Map<String, dynamic>
          ? TripModel.fromJson(json['trip'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reported_user_id': reportedUserId,
      'car_id': carId,
      'trip_id': tripId,
      'title': title,
      'description': description,
      'status': status,
      'status_text': statusText,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
      if (reportedUser != null) 'reported_user': reportedUser!.toJson(),
    };
  }

  ReportModel copyWith({
    int? id,
    int? userId,
    int? reportedUserId,
    int? carId,
    int? tripId,
    String? title,
    String? description,
    int? status,
    String? statusText,
    DateTime? resolvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    UserModel? reportedUser,
    CarModel? car,
    TripModel? trip,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      carId: carId ?? this.carId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      reportedUser: reportedUser ?? this.reportedUser,
      car: car ?? this.car,
      trip: trip ?? this.trip,
    );
  }

  String getStatusDisplay() {
    if (statusText != null && statusText!.isNotEmpty) {
      return statusText!;
    }
    switch (status) {
      case 0:
        return 'Chờ xử lý';
      case 1:
        return 'Đã xử lý';
      case 2:
        return 'Đã từ chối';
      default:
        return 'Không xác định';
    }
  }
}
