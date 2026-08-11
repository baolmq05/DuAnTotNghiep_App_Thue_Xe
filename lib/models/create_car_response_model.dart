class CreateCarResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  CreateCarResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateCarResponse.fromJson(Map<String, dynamic> json) {
    return CreateCarResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Đăng ký xe xử lý thành công',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }
}
