import 'package:flutter/foundation.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_brand_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_feature_item_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_type_item_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/create_car_request_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/create_car_response_model.dart';

import '../models/car_model.dart';
import 'base_service.dart';

class CarService extends BaseService {
  Future<List<CarBrand>> getCarBrands() async {
    try {
      final response = await get('api/car-brands');
      if (response != null && response['data'] != null) {
        final List data = response['data'] as List;
        return data.map((e) => CarBrand.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi getCarBrands: $e');
      rethrow;
    }
  }

  Future<List<CarTypeItem>> getCarTypes(int brandId) async {
    try {
      final response = await get('api/car-brands/$brandId/types');
      if (response != null && response['data'] != null) {
        final List data = response['data'] as List;
        return data.map((e) => CarTypeItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi getCarTypes: $e');
      rethrow;
    }
  }

  Future<List<CarFeatureItem>> getCarFeatures() async {
    try {
      final response = await get('api/car-features');
      if (response != null && response['data'] != null) {
        final List data = response['data'] as List;
        return data.map((e) => CarFeatureItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi getCarFeatures: $e');
      rethrow;
    }
  }

  Future<CreateCarResponse> createCar(CreateCarRequest request) async {
    try {
      final response = await store(
        'api/cars',
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        return CreateCarResponse.fromJson(response);
      }

      return CreateCarResponse(
        success: false,
        message: 'Không nhận được phản hồi hợp lệ từ máy chủ.',
      );
    } catch (e) {
      debugPrint('Lỗi khi đăng ký xe: $e');
      if (e is ApiException) {
        return CreateCarResponse(
          success: false,
          message: e.message,
        );
      }
      return CreateCarResponse(
        success: false,
        message: 'Có lỗi xảy ra: $e',
      );
    }
  }

  Future<List<Car>> getCars({Map<String, String>? queryParameters}) async {
    final endpoint = 'api/cars';
    final response = queryParameters == null || queryParameters.isEmpty
        ? await get(endpoint)
        : await get(
            Uri(path: endpoint, queryParameters: queryParameters).toString(),
          );

    final List data = response['data'];

    return data.map((e) => Car.fromJson(e)).toList();
  }

  Future<Car_Detail> getCarDetail({required int id}) async {
    final response = await get('api/cars/$id');
    final Car_Detail data = Car_Detail.fromJson(response['data']);
    return data;
  }
}
