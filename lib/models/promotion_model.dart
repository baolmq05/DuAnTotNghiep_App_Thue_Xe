class PromotionImage {
  final int id;
  final String imageUrl;

  PromotionImage({
    required this.id,
    required this.imageUrl,
  });

  factory PromotionImage.fromJson(Map<String, dynamic> json) {
    return PromotionImage(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}

class Promotion {
  final int id;
  final String code;
  final String name;
  final String description;
  final String discountType;
  final num discountValue;
  final String startDate;
  final String endDate;
  final int usageLimit;
  final int perUserLimit;
  final String status;
  final List<PromotionImage> images;

  Promotion({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.perUserLimit,
    required this.status,
    required this.images,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? '0',
      discountValue: json['discount_value'] is num
          ? json['discount_value'] as num
          : num.tryParse(json['discount_value']?.toString() ?? '') ?? 0,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      usageLimit: json['usage_limit'] is int
          ? json['usage_limit'] as int
          : int.tryParse(json['usage_limit']?.toString() ?? '') ?? 0,
      perUserLimit: json['per_user_limit'] is int
          ? json['per_user_limit'] as int
          : int.tryParse(json['per_user_limit']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? '1',
      images: json['images'] is List
          ? (json['images'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map((e) => PromotionImage.fromJson(e))
              .toList()
          : [],
    );
  }
}