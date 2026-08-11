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

  Future<List<TripModel>> getOwnerTrips() async {
    try {
      final response = await get('api/trips', requiresAuth: true);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        List dataList = [];
        if (data is Map<String, dynamic>) {
          dataList = (data['owner_trips'] ?? data['owner'] ?? []) as List;
        } else if (data is List) {
          dataList = data;
        }
        return dataList.map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách đơn thuê xe cho chủ xe: $e');
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

  // Tạo giao dịch ZaloPay qua API Backend (Sandbox)
  Future<Map<String, dynamic>> createZaloPayPayment(
    int tripId, {
    double? amount,
    String? paymentType,
    String? customEndpoint,
  }) async {
    try {
      final endpoint = customEndpoint ?? 'api/auth/zalopay/create-payment';
      final response = await store(
        endpoint,
        body: {
          'trip_id': tripId,
          if (amount != null) 'amount': amount,
          if (paymentType != null) 'payment_type': paymentType,
        },
        requiresAuth: true,
      );

      if (response != null) {
        // Hỗ trợ parse mềm dẻo tùy cấu trúc dữ liệu của backend trả về
        final success = response['success'] ?? (response['return_code'] == 1) ?? false;
        final data = response['data'] ?? response;
        
        // Trích xuất app_trans_id từ nhiều vị trí phản hồi có thể có
        final appTransId = response['app_trans_id'] ?? 
                           response['appTransId'] ?? 
                           (response['zalopay'] != null ? response['zalopay']['app_trans_id'] : null) ??
                           (response['data'] != null ? response['data']['app_trans_id'] : null);
        
        return {
          'success': success,
          'message': response['message'] ?? response['return_message'] ?? 'Thành công',
          'order_url': response['payment_url'] ?? data['order_url'] ?? data['orderUrl'] ?? response['order_url'],
          'zp_trans_token': data['zp_trans_token'] ?? data['zpTransToken'] ?? response['zp_trans_token'],
          'app_trans_id': appTransId,
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi từ backend.',
      };
    } catch (e) {
      debugPrint('Lỗi khi gọi API thanh toán ZaloPay: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Gọi API verify để chủ động truy vấn trạng thái thanh toán từ ZaloPay (Không cần ngrok)
  Future<Map<String, dynamic>> verifyZaloPayPayment(String appTransId) async {
    try {
      final response = await get(
        'api/zalopay/verify?app_trans_id=$appTransId',
        requiresAuth: true,
      );

      if (response != null) {
        return {
          'success': response['success'] ?? false,
          'message': response['message'] ?? 'Thành công',
          'data': response['data'],
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi xác thực từ backend.',
      };
    } catch (e) {
      debugPrint('Lỗi khi gọi API xác thực ZaloPay: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Gửi yêu cầu gia hạn chuyến đi
  Future<Map<String, dynamic>> requestExtension(
    int tripId, {
    required String endDate,
    required int extendedDays,
    required double extensionAmount,
  }) async {
    try {
      final response = await store(
        'api/trips/$tripId/extension-request',
        body: {
          'end_date': endDate,
          'extended_days': extendedDays,
          'extension_amount': extensionAmount,
        },
        requiresAuth: true,
      );

      if (response != null) {
        return {
          'success': response['success'] ?? false,
          'message': response['message'] ?? 'Gửi yêu cầu gia hạn thành công',
          'data': response['data'],
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi từ hệ thống.',
      };
    } catch (e) {
      debugPrint('Lỗi khi gửi yêu cầu gia hạn: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Tạo giao dịch ZaloPay để thanh toán phí gia hạn
  Future<Map<String, dynamic>> createExtensionPayment(int tripId) async {
    try {
      final response = await store(
        'api/auth/zalopay/create-payment',
        body: {
          'trip_id': tripId,
          'payment_type': 'extension',
        },
        requiresAuth: true,
      );

      if (response != null) {
        final success = response['success'] ?? (response['return_code'] == 1) ?? false;
        final data = response['data'] ?? response;

        final appTransId = response['app_trans_id'] ??
            response['appTransId'] ??
            (response['zalopay'] != null ? response['zalopay']['app_trans_id'] : null) ??
            (response['data'] != null ? response['data']['app_trans_id'] : null);

        return {
          'success': success,
          'message': response['message'] ?? response['return_message'] ?? 'Thành công',
          'order_url': response['payment_url'] ?? data['order_url'] ?? data['orderUrl'] ?? response['order_url'],
          'zp_trans_token': data['zp_trans_token'] ?? data['zpTransToken'] ?? response['zp_trans_token'],
          'app_trans_id': appTransId,
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi từ backend.',
      };
    } catch (e) {
      debugPrint('Lỗi khi gọi API thanh toán gia hạn ZaloPay: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Gửi yêu cầu trả xe
  Future<Map<String, dynamic>> requestReturn(int tripId) async {
    try {
      final response = await store(
        'api/trips/$tripId/return-request',
        body: {},
        requiresAuth: true,
      );

      if (response != null) {
        return {
          'success': response['success'] ?? false,
          'message': response['message'] ?? 'Gửi yêu cầu trả xe thành công',
          'data': response['data'],
        };
      }

      return {
        'success': false,
        'message': 'Không nhận được phản hồi từ hệ thống.',
      };
    } catch (e) {
      debugPrint('Lỗi khi gửi yêu cầu trả xe: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Gửi đánh giá cho chuyến đi
  Future<Map<String, dynamic>> submitReview(
    int tripId, {
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await store(
        'api/trips/$tripId/reviews',
        body: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        requiresAuth: true,
      );

      if (response != null && response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Gửi đánh giá thành công!',
          'data': response['data'],
        };
      }

      return {
        'success': false,
        'message': response?['message'] ?? 'Không thể gửi đánh giá.',
      };
    } catch (e) {
      debugPrint('Lỗi khi gửi đánh giá cho chuyến đi $tripId: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra khi gửi đánh giá: $e'};
    }
  }

  // Xác nhận chuyến đi (Chủ xe duyệt đơn)
  Future<Map<String, dynamic>> confirmTrip(int tripId) async {
    try {
      final response = await update(
        'api/trips/$tripId/confirm',
        body: {},
        requiresAuth: true,
      );

      if (response != null && response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Xác nhận chuyến đi thành công!',
        };
      }

      return {
        'success': false,
        'message': response?['message'] ?? 'Không thể xác nhận chuyến đi.',
      };
    } catch (e) {
      debugPrint('Lỗi khi xác nhận chuyến đi $tripId: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Từ chối chuyến đi (Chủ xe từ chối đơn)
  Future<Map<String, dynamic>> rejectTrip(int tripId, {String? reason}) async {
    try {
      final response = await update(
        'api/trips/$tripId/reject',
        body: reason != null ? {'reason': reason} : {},
        requiresAuth: true,
      );

      if (response != null && response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Từ chối yêu cầu thuê xe thành công!',
        };
      }

      return {
        'success': false,
        'message': response?['message'] ?? 'Không thể từ chối yêu cầu thuê xe.',
      };
    } catch (e) {
      debugPrint('Lỗi khi từ chối chuyến đi $tripId: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }
}


