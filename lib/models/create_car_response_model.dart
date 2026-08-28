import 'package:duantotnghiep_app_thue_xe/utils/error_helper.dart';

class CreateCarResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? errors;

  CreateCarResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory CreateCarResponse.fromJson(Map<String, dynamic> json) {
    final bool success = json['success'] == true;
    String message = json['message']?.toString() ?? 'Đăng ký xe xử lý thành công';
    Map<String, dynamic>? errors;

    if (!success) {
      if (json.containsKey('errors')) {
        final formattedErrors = formatValidationErrors(json['errors']);
        if (formattedErrors.isNotEmpty) {
          message = formattedErrors;
        }
        if (json['errors'] is Map<String, dynamic>) {
          errors = json['errors'] as Map<String, dynamic>;
        }
      }
    }

    return CreateCarResponse(
      success: success,
      message: message,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      errors: errors,
    );
  }
}
