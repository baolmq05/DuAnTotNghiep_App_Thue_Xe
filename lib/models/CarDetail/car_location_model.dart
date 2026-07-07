import 'dart:core';

class CarLocation {
  final int id;
  final String location;
  final String address;
  final String? createdAt;
  final String? updatedAt;

  CarLocation({
    required this.id,
    required this.location,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarLocation.fromJson(Map<String, dynamic> json) {
    return CarLocation(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      location: json['location']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
