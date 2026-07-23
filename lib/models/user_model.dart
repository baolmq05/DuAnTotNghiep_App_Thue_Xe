class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final int? gender;
  final String? dob;
  final int status;
  final int roleId;
  final int? walletId;
  final int? drivingLicenseId;
  final DrivingLicenseModel? drivingLicense;
  final int tripsCount;
  final double rating;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.gender,
    this.dob,
    required this.status,
    required this.roleId,
    this.walletId,
    this.drivingLicenseId,
    this.drivingLicense,
    this.tripsCount = 0,
    this.rating = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json);

    return UserModel(
      id: userData['id'] is int ? userData['id'] as int : int.tryParse(userData['id']?.toString() ?? '') ?? 0,
      name: userData['name'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      phone: userData['phone'] as String?,
      avatar: userData['avatar'] as String?,
      gender: userData['gender'] as int?,
      dob: userData['DOB'] as String?,
      status: userData['status'] as int? ?? 1,
      roleId: userData['role_id'] as int? ?? 2,
      walletId: userData['wallet_id'] as int?,
      drivingLicenseId: userData['driving_license_id'] as int?,
      drivingLicense: userData['driving_license'] != null
          ? DrivingLicenseModel.fromJson(userData['driving_license'] as Map<String, dynamic>)
          : null,
      tripsCount: userData['trips_count'] is int
          ? userData['trips_count'] as int
          : (userData['tripsCount'] is int
              ? userData['tripsCount'] as int
              : int.tryParse(userData['trips_count']?.toString() ?? userData['tripsCount']?.toString() ?? '') ?? 0),
      rating: double.tryParse(
              userData['rating']?.toString() ??
              userData['reviews_avg_rating']?.toString() ??
              userData['avg_rating']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'gender': gender,
      'DOB': dob,
      'status': status,
      'role_id': roleId,
      'wallet_id': walletId,
      'driving_license_id': drivingLicenseId,
      'driving_license': drivingLicense?.toJson(),
      'trips_count': tripsCount,
      'rating': rating,
    };
  }
}

class DrivingLicenseModel {
  final int id;
  final String drivingLicenseNumber;
  final String fullName;
  final String dob;
  final String image;
  final int status;

  DrivingLicenseModel({
    required this.id,
    required this.drivingLicenseNumber,
    required this.fullName,
    required this.dob,
    required this.image,
    required this.status,
  });

  factory DrivingLicenseModel.fromJson(Map<String, dynamic> json) {
    return DrivingLicenseModel(
      id: json['id'] as int? ?? 0,
      drivingLicenseNumber: json['driving_license_number'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      dob: json['DOB'] as String? ?? '',
      image: json['image'] as String? ?? '',
      status: json['status'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driving_license_number': drivingLicenseNumber,
      'full_name': fullName,
      'DOB': dob,
      'image': image,
      'status': status,
    };
  }
}
