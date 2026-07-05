import 'package:flutter/foundation.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';

class TripService extends BaseService {
  Future<List<TripModel>> getMyTrips() async {
    try {
      final response = await get('api/my-trips');
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
      final response = await get('api/trips/$id');
      if (response != null && response['success'] == true) {
        return TripModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi khi lấy chi tiết chuyến đi $id: $e');
      rethrow;
    }
  }
}
