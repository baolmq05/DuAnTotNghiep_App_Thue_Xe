class CarImage {
  final int id;
  final int isThumbnail;
  final String imageUrl;
  final int carId;
  final String createdAt;
  final String updatedAt;

  CarImage({
    required this.id,
    required this.isThumbnail,
    required this.imageUrl,
    required this.carId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      isThumbnail: json['is_thumbnail'] is int
          ? json['is_thumbnail']
          : int.tryParse(json['is_thumbnail']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      carId: json['car_id'] is int ? json['car_id'] : int.tryParse(json['car_id']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
