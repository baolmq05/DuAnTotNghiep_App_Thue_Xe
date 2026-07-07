class CarOwner {
  final int id;
  final String name;
  final String? avatar;
  final String? phone;
  final String? gender;
  final String? drivingLicense;

  CarOwner({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
    this.gender,
    this.drivingLicense,
  });

  factory CarOwner.fromJson(Map<String, dynamic> json) {
    return CarOwner(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      drivingLicense: json['driving_license']?.toString(),
    );
  }
}
