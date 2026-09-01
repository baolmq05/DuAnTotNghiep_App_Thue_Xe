import 'dart:convert';
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
        Map<String, dynamic>? errors;
        try {
          if (e.body != null) {
            final json = jsonDecode(e.body!);
            if (json is Map && json.containsKey('errors')) {
              errors = json['errors'] is Map<String, dynamic> ? json['errors'] as Map<String, dynamic> : null;
            }
          }
        } catch (_) {}
        return CreateCarResponse(
          success: false,
          message: e.message,
          errors: errors,
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

  /// Cập nhật trạng thái xe (ví dụ: hoạt động, tạm khóa)
  Future<bool> updateCarStatus(int carId, int status, {String? reason}) async {
    try {
      // 1. Lấy thông tin chi tiết đầy đủ của xe
      final carDetail = await getCarDetail(id: carId);

      // 2. Chuyển đổi thông tin sang cấu trúc của update request (đầy đủ các trường bắt buộc của Laravel)
      final int brandId = carDetail.carBrandId != 0 
          ? carDetail.carBrandId 
          : (carDetail.carType.carBrandId != 0 ? carDetail.carType.carBrandId : carDetail.carBrand.id);
      
      final int typeId = carDetail.carTypeId != 0 
          ? carDetail.carTypeId 
          : carDetail.carType.id;

      final double price = double.tryParse(carDetail.unitPrice) ?? 0.0;
      final double discount = double.tryParse(carDetail.discountValue) ?? 0.0;
      final int manufactureYr = int.tryParse(carDetail.manufactureYear) ?? 2020;
      final int seat = int.tryParse(carDetail.seatCount) ?? 5;

      final bool isDelivery = carDetail.deliveryOption.status == 1;

      final String fullAddress = carDetail.carLocation.address;
      String locationStr = '';
      if (fullAddress.isNotEmpty) {
        final parts = fullAddress.split(',');
        if (parts.isNotEmpty) {
          locationStr = parts.last.trim();
        }
      }

      final List<int> featuresList = carDetail.features.map((f) => f.id).toList();
      final List<String> imagesList = carDetail.images.map((img) => img.imageUrl).toList();
      int thumbnailIdx = carDetail.images.indexWhere((img) => img.isThumbnail == 1);
      if (thumbnailIdx == -1) thumbnailIdx = 0;

      // 3. Tạo payload đầy đủ
      final Map<String, dynamic> body = {
        'car_brand_id': brandId,
        'car_type_id': typeId,
        'license_plate': carDetail.licensePlate,
        'VIN': carDetail.VIN,
        'engine_number': carDetail.engineNumber,
        'fuel_consumption': carDetail.fuelConsumption.toDouble(),
        'unit_price': price.toInt(),
        'discount_value': discount.toInt(),
        'description': carDetail.description ?? '',
        'rental_terms': carDetail.rentalTerms,
        'seat_count': seat,
        'manufacture_year': manufactureYr,
        'fuel_type': carDetail.fuelType,
        'transmission': carDetail.transmission,
        'location': locationStr,
        'address': fullAddress,
        'delivery_enabled': isDelivery ? '1' : '0',
        'delivery_max_distance': isDelivery ? carDetail.deliveryOption.maxDistance.toDouble() : 0,
        'delivery_fee': isDelivery ? carDetail.deliveryOption.feeDistance.toInt() : 0,
        'delivery_free_distance': isDelivery ? carDetail.deliveryOption.freeDistance.toDouble() : 0,
        'features': featuresList,
        'images': imagesList,
        'thumbnail_index': thumbnailIdx,
        'status': status,
      };

      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      // 4. Gửi PUT để cập nhật với đầy đủ các trường
      final response = await update(
        'api/cars/$carId',
        body: body,
        requiresAuth: true,
      );
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Lỗi updateCarStatus: $e');
      rethrow;
    }
  }

  /// Xóa xe khỏi hệ thống
  Future<bool> deleteCar(int carId) async {
    try {
      final response = await delete(
        'api/cars/$carId',
        requiresAuth: true,
      );
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Lỗi deleteCar: $e');
      return false;
    }
  }

  /// Cập nhật thông tin xe
  Future<CreateCarResponse> updateCar(int carId, CreateCarRequest request) async {
    try {
      final response = await update(
        'api/cars/$carId',
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
      debugPrint('Lỗi khi cập nhật xe: $e');
      if (e is ApiException) {
        Map<String, dynamic>? errors;
        try {
          if (e.body != null) {
            final json = jsonDecode(e.body!);
            if (json is Map && json.containsKey('errors')) {
              errors = json['errors'] is Map<String, dynamic> ? json['errors'] as Map<String, dynamic> : null;
            }
          }
        } catch (_) {}
        return CreateCarResponse(
          success: false,
          message: e.message,
          errors: errors,
        );
      }
      return CreateCarResponse(
        success: false,
        message: 'Có lỗi xảy ra: $e',
      );
    }
  }
}
