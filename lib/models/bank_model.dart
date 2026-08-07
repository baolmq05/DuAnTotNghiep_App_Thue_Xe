class BankModel {
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final bool supported;

  BankModel({
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.supported,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      bin: json['bin'] as String? ?? '',
      shortName: json['short_name'] as String? ?? '',
      supported: json['supported'] is bool
          ? json['supported'] as bool
          : (json['supported']?.toString() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'bin': bin,
      'short_name': shortName,
      'supported': supported,
    };
  }
}
