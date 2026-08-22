import 'base_service.dart';
import 'package:flutter/foundation.dart';
import 'package:duantotnghiep_app_thue_xe/models/owner_report_summary_model.dart';

class OwnerProfileService extends BaseService {
  /// Lấy dữ liệu đánh giá và hồ sơ chủ xe/khách thuê
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

  /// Lấy tổng hợp Strike / Vi phạm và báo cáo của chủ xe hiện tại
  /// Endpoint: GET /api/owner/reports/summary
  Future<OwnerReportSummaryModel?> fetchOwnerReportSummary() async {
    try {
      debugPrint('[OwnerProfileService] Đang gọi GET api/owner/reports/summary ...');
      final response = await get('api/owner/reports/summary', requiresAuth: true);
      debugPrint('[OwnerProfileService] Response api/owner/reports/summary: $response');

      if (response != null && response is Map) {
        return OwnerReportSummaryModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('[OwnerProfileService] Lỗi fetchOwnerReportSummary: $e');
      return null;
    }
  }
}