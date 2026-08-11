class CarTypeItem {
  final int id;
  final String typeName;
  final int? seatCount;

  CarTypeItem({
    required this.id,
    required this.typeName,
    this.seatCount,
  });

  factory CarTypeItem.fromJson(Map<String, dynamic> json) {
    return CarTypeItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      typeName: json['type_name']?.toString() ?? json['name']?.toString() ?? '',
      seatCount: json['seat_count'] is int ? json['seat_count'] as int : int.tryParse(json['seat_count']?.toString() ?? ''),
    );
  }
}
