class CarFeature {
  final int id;
  final String featureName;
  final String icon;
  final String description;
  final int status;
  final String createdAt;
  final String updatedAt;

  CarFeature({
    required this.id,
    required this.featureName,
    required this.icon,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarFeature.fromJson(Map<String, dynamic> json) {
    return CarFeature(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      featureName: json['feature_name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
