import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class WalletService extends BaseService {
  /// Lấy thông tin chi tiết ví và lịch sử giao dịch (có thể lọc theo tháng/năm)
  Future<Map<String, dynamic>> fetchWalletDetails({int? month, int? year}) async {
    String endpoint = 'api/auth/wallet';
    final Map<String, String> queryParams = {};
    
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    if (queryParams.isNotEmpty) {
      final queryString = Uri(queryParameters: queryParams).query;
      endpoint = '$endpoint?$queryString';
    }

    final response = await get(endpoint, requiresAuth: true);
    return response as Map<String, dynamic>;
  }

  /// Gửi yêu cầu rút tiền từ ví
  Future<Map<String, dynamic>> withdraw(int amount, String? description) async {
    final response = await store(
      'api/auth/wallet/withdraw',
      body: {
        'amount': amount,
        if (description != null && description.isNotEmpty) 'description': description,
      },
      requiresAuth: true,
    );
    return response as Map<String, dynamic>;
  }
}
