// import '../models/owner_profile_model.dart';
import 'base_service.dart';
import 'package:flutter/foundation.dart';

class OwnerProfileService extends BaseService {
  Future<Map<String, dynamic>?> fetchProfileReviews({
    required int targetId,
    required bool isOwner,
  }) async {
    try {
      final url = 'api/reviews/$targetId?isOwner=$isOwner';
      final response = await get(url, requiresAuth: true);

      if (response != null && response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      }
      throw Exception('Không thể tải dữ liệu hồ sơ.');
    } catch (e) {
      debugPrint('Lỗi OwnerProfileService: $e');
      rethrow;
    }
  }
}