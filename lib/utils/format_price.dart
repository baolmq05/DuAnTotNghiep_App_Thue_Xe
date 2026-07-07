/// Hàm format giá tiền Việt Nam
/// Ví dụ: formatPrice('350000') => '350.000'
///        formatPrice('70000') => '70.000'
String formatPrice(String price) {
  // Loại bỏ phần thập phân nếu có (vd: "3000.00" -> "3000")
  final cleanPrice = price.split('.').first;

  // Parse thành số
  final number = int.tryParse(cleanPrice) ?? 0;

  // Format với dấu chấm phân cách hàng nghìn
  final result = number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );

  return result;
}

/// Format giá tiền có đơn vị
/// Ví dụ: formatPriceWithUnit('350000') => '350.000đ'
String formatPriceWithUnit(String price, {String unit = 'đ'}) {
  return '${formatPrice(price)}$unit';
}
