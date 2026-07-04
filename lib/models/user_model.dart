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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      gender: json['gender'] as int?,
      dob: json['DOB'] as String?,
      status: json['status'] as int? ?? 1,
      roleId: json['role_id'] as int? ?? 2,
      walletId: json['wallet_id'] as int?,
      drivingLicenseId: json['driving_license_id'] as int?,
      drivingLicense: json['driving_license'] != null
          ? DrivingLicenseModel.fromJson(json['driving_license'] as Map<String, dynamic>)
          : null,
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
