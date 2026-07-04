class PromotionImage {
  final int id;
  final String imageUrl;

  PromotionImage({
    required this.id,
    required this.imageUrl,
  });

  factory PromotionImage.fromJson(Map<String, dynamic> json) {
    return PromotionImage(
      id: json['id'],
      imageUrl: json['image_url'] ?? '',
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
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discount_type'].toString(),
      discountValue: json['discount_value'],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      usageLimit: json['usage_limit'],
      perUserLimit: json['per_user_limit'],
      status: json['status'].toString(),
      images: (json['images'] as List<dynamic>)
          .map((e) => PromotionImage.fromJson(e))
          .toList(),
    );
  }
}