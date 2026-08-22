import 'package:flutter/foundation.dart';
import 'package:duantotnghiep_app_thue_xe/models/report_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class ReportService extends BaseService {
  /// Lấy danh sách báo cáo của người dùng hiện tại từ API
  Future<List<ReportModel>> getMyReports() async {
    try {
      final response = await get('api/reports', requiresAuth: true);
      if (response != null) {
        // Hỗ trợ Laravel API trả về bọc trong object success và data
        if (response is Map && response['success'] == true) {
          final List dataList = response['data'] as List? ?? [];
          return dataList.map((json) => ReportModel.fromJson(json)).toList();
        }
        // Trường hợp API trả về thẳng danh sách
        if (response is List) {
          return response.map((json) => ReportModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách báo cáo: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết một báo cáo theo ID
  Future<ReportModel?> getReportDetail(int id) async {
    try {
      final response = await get('api/reports/$id', requiresAuth: true);
      if (response != null) {
        if (response is Map && response['success'] == true && response['data'] != null) {
          return ReportModel.fromJson(response['data']);
        }
        if (response is Map<String, dynamic>) {
          return ReportModel.fromJson(response);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi khi lấy chi tiết báo cáo $id: $e');
      rethrow;
    }
  }

  /// Gửi một báo cáo/khiếu nại mới lên hệ thống
  Future<Map<String, dynamic>> createReport({
    required String title,
    required String description,
    int? reportedUserId,
    int? carId,
    int? tripId,
  }) async {
    try {
      final response = await store(
        'api/reports',
        body: {
          'title': title,
          'description': description,
          if (reportedUserId != null) 'reported_user_id': reportedUserId,
          if (carId != null) 'car_id': carId,
          if (tripId != null) 'trip_id': tripId,
        },
        requiresAuth: true,
      );

      if (response != null) {
        final success = response['success'] ?? false;
        return {
          'success': success,
          'message': response['message'] ?? (success ? 'Gửi báo cáo thành công!' : 'Gửi báo cáo thất bại!'),
          'data': response['data'] != null ? ReportModel.fromJson(response['data']) : null,
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi từ hệ thống.',
      };
    } on ApiException catch (e) {
      debugPrint('Lỗi khi tạo báo cáo: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Lỗi khi tạo báo cáo: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }
}
