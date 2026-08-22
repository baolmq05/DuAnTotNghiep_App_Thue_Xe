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
    required int tripId,
    required int reportType,
    required String description,
    List<String>? images,
  }) async {
    try {
      final response = await store(
        'api/reports',
        body: {
          'trip_id': tripId,
          'report_type': reportType,
          'description': description,
          if (images != null) 'images': images,
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

  /// Thu hồi báo cáo/khiếu nại
  Future<Map<String, dynamic>> cancelReport(int reportId) async {
    try {
      final response = await store(
        'api/reports/$reportId/revoke',
        body: {},
        requiresAuth: true,
      );

      if (response != null) {
        final success = response['success'] ?? false;
        return {
          'success': success,
          'message': response['message'] ?? (success ? 'Thu hồi khiếu nại thành công!' : 'Thu hồi khiếu nại thất bại!'),
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi từ hệ thống.',
      };
    } on ApiException catch (e) {
      debugPrint('Lỗi khi thu hồi báo cáo $reportId: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Lỗi khi thu hồi báo cáo $reportId: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }
}
