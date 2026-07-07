class AddressModel {
  final int id;
  final String addressName;
  final int userId;

  AddressModel({
    required this.id,
    required this.addressName,
    required this.userId,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int? ?? 0,
      addressName: json['address_name'] as String? ?? '',
      userId: json['user_id'] is String
          ? int.tryParse(json['user_id'] as String) ?? 0
          : json['user_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_name': addressName,
      'user_id': userId,
    };
  }
}
