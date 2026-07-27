import 'package:flutter/foundation.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class TripService extends BaseService {
  Future<List<TripModel>> getMyTrips() async {
    try {
      final response = await get('api/my-trips', requiresAuth: true);
      if (response != null && response['success'] == true) {
        final List dataList = response['data'] as List? ?? [];
        return dataList.map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách chuyến đi: $e');
      rethrow;
    }
  }

  Future<TripModel?> getTripDetail(int id) async {
    try {
      final response = await get('api/trips/$id', requiresAuth: true);
      if (response != null && response['success'] == true) {
        return TripModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi khi lấy chi tiết chuyến đi $id: $e');
      rethrow;
    }
  }

  // Tạo chuyến đi mới
  Future<Map<String, dynamic>> createTrip(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final response = await store(
        'api/trips',
        body: bookingData,
        requiresAuth: true,
      );

      if (response != null) {
        return {
          'success': response['success'] ?? false,
          'message': response['message'] ?? 'Xử lý thành công',
          'data': response['data'] != null
              ? TripModel.fromJson(response['data'])
              : null,
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi từ hệ thống.',
      };
    } catch (e) {
      debugPrint('Lỗi khi tạo yêu cầu thuê xe: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Hủy chuyến đi (khách thuê)
  Future<Map<String, dynamic>> cancelTrip(int tripId, {String? reason}) async {
    try {
      final response = await store(
        'api/trips/$tripId/cancel',
        body: reason != null ? {'reason': reason} : {},
        requiresAuth: true,
      );

      if (response != null && response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Hủy chuyến thành công!',
        };
      }

      return {
        'success': false,
        'message': response?['message'] ?? 'Không thể hủy chuyến đi.',
      };
    } catch (e) {
      debugPrint('Lỗi khi hủy chuyến đi $tripId: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra khi hủy chuyến: $e'};
    }
  }
}
