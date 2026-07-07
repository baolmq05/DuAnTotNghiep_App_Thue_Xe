import 'dart:core';

class CarBrand {
  final int id;
  final String brand_name;
  final String? createdAt;
  final String? updatedAt;

  CarBrand({
    required this.id,
    required this.brand_name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarBrand.fromJson(Map<String, dynamic> json) {
    return CarBrand(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      brand_name: json['brand_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
