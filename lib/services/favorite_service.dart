import 'package:flutter/foundation.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class FavoriteService extends BaseService {
  /// Lấy danh sách xe yêu thích từ backend
  Future<List<Car>> getFavorites() async {
    try {
      final response = await get('api/favorites', requiresAuth: true);
      if (response != null && response['success'] == true) {
        final List dataList = response['data'] as List? ?? [];
        return dataList
            .map((item) {
              if (item['car'] != null) {
                return Car.fromJson(item['car'] as Map<String, dynamic>);
              }
              return null;
            })
            .whereType<Car>()
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách yêu thích: $e');
      rethrow;
    }
  }

  /// Thêm xe vào danh sách yêu thích
  Future<bool> addFavorite(int carId) async {
    try {
      final response = await store(
        'api/favorites',
        body: {'car_id': carId},
        requiresAuth: true,
      );
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Lỗi khi thêm xe $carId vào danh sách yêu thích: $e');
      rethrow;
    }
  }

  /// Xóa xe khỏi danh sách yêu thích
  Future<bool> removeFavorite(int carId) async {
    try {
      final response = await delete(
        'api/favorites/$carId',
        requiresAuth: true,
      );
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Lỗi khi xóa xe $carId khỏi danh sách yêu thích: $e');
      rethrow;
    }
  }
}
