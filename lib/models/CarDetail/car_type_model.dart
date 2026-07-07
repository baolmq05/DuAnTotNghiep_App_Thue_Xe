import 'dart:core';

class CarType {
  final int id;
  final String type_name;
  final int carBrandId;
  final String? createdAt;
  final String? updatedAt;

  CarType({
    required this.id,
    required this.type_name,
    required this.carBrandId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarType.fromJson(Map<String, dynamic> json) {
    return CarType(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type_name: json['type_name']?.toString() ?? '',
      carBrandId: json['car_brand_id'] is int
          ? json['car_brand_id']
          : int.tryParse(json['car_brand_id']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
