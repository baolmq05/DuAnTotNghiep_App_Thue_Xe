/// Hàm định dạng các lỗi validate
String formatValidationErrors(dynamic errors) {
  if (errors == null) return '';
  if (errors is String) return errors;
  if (errors is List) {
    return errors.map((e) => e.toString()).join('\n');
  }
  if (errors is Map) {
    final List<String> messages = [];
    errors.forEach((key, value) {
      if (value is List) {
        messages.addAll(value.map((e) => e.toString()));
      } else if (value is Map) {
        value.forEach((k, v) {
          if (v is List) {
            messages.addAll(v.map((e) => e.toString()));
          } else {
            messages.add(v.toString());
          }
        });
      } else {
        messages.add(value.toString());
      }
    });
    return messages.join('\n');
  }
  return errors.toString();
}
