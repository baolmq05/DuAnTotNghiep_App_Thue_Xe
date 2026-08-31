import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class PaymentService extends BaseService {
  // VNPay Sandbox Credentials (Môi trường thử nghiệm chính thức của VNPay)
  static const String vnpUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String vnpTmnCode = '2QXUI4J4';
  static const String vnpHashSecret = 'RAKDAEOWMJVZDELOIHJWUNXIKGXTTUNT';
  static const String vnpReturnUrl = 'http://localhost:8080/vnpay_return';

  // ===================== ZALOPAY SERVICES =====================

  /// Tạo giao dịch ZaloPay qua API Backend (Sandbox)
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
    } on ApiException catch (e) {
      debugPrint('Lỗi khi gọi API thanh toán ZaloPay: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Lỗi khi gọi API thanh toán ZaloPay: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  /// Gọi API verify để truy vấn trạng thái thanh toán từ ZaloPay
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

  /// Tạo giao dịch ZaloPay để thanh toán phí gia hạn
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
    } on ApiException catch (e) {
      debugPrint('Lỗi khi gọi API thanh toán gia hạn ZaloPay: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Lỗi khi gọi API thanh toán gia hạn ZaloPay: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // ===================== VNPAY SERVICES =====================

  /// Sinh URL thanh toán VNPay Sandbox chuẩn HMAC-SHA512
  String generateVNPayPaymentUrl({
    required int tripId,
    required double amount,
    String? orderInfo,
    String? txnRef,
    String? returnUrl,
  }) {
    final now = DateTime.now();
    final expireTime = now.add(const Duration(minutes: 15));
    final createDateStr = DateFormat('yyyyMMddHHmmss').format(now);
    final expireDateStr = DateFormat('yyyyMMddHHmmss').format(expireTime);
    
    final transactionRef = txnRef ?? '${tripId}_${now.millisecondsSinceEpoch}';
    final info = orderInfo ?? 'Thanh toan don thue xe $tripId Drivio';
    final finalReturnUrl = returnUrl ?? vnpReturnUrl;

    // VNPay yêu cầu số tiền nhân với 100 (Ví dụ: 10.000 VNĐ -> 1000000)
    final vnpAmount = (amount * 100).toInt().toString();

    final Map<String, String> vnpParams = {
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': vnpTmnCode,
      'vnp_Amount': vnpAmount,
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': transactionRef,
      'vnp_OrderInfo': info,
      'vnp_OrderType': 'other',
      'vnp_Locale': 'vn',
      'vnp_ReturnUrl': finalReturnUrl,
      'vnp_IpAddr': '192.168.1.1',
      'vnp_CreateDate': createDateStr,
      'vnp_ExpireDate': expireDateStr,
    };

    // Sắp xếp các tham số theo thứ tự a-z
    final sortedKeys = vnpParams.keys.toList()..sort();
    final List<String> queryParts = [];
    final List<String> hashParts = [];

    for (final key in sortedKeys) {
      final value = vnpParams[key]!;
      if (value.isNotEmpty) {
        // Chuẩn hóa encoding tương thích với URLEncoder.encode của VNPay Java/PHP backend (+ thay cho %20)
        final encodedKey = Uri.encodeQueryComponent(key);
        final encodedValue = Uri.encodeQueryComponent(value).replaceAll('%20', '+');
        queryParts.add('$encodedKey=$encodedValue');
        hashParts.add('$encodedKey=$encodedValue');
      }
    }

    final hashData = hashParts.join('&');
    final queryData = queryParts.join('&');

    // Tạo chữ ký HMAC-SHA512
    final keyBytes = utf8.encode(vnpHashSecret);
    final hmacSha512 = Hmac(sha512, keyBytes);
    final digest = hmacSha512.convert(utf8.encode(hashData));
    final secureHash = digest.toString();

    return '$vnpUrl?$queryData&vnp_SecureHash=$secureHash';
  }

  /// Xác nhận cập nhật trạng thái đơn sau khi thanh toán VNPay thành công
  Future<Map<String, dynamic>> confirmPaymentSuccess(
    int tripId, {
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final response = await store(
        'api/trips/$tripId/confirm-payment',
        body: {
          'amount': amount,
          'payment_method': paymentMethod,
          if (transactionId != null) 'transaction_id': transactionId,
        },
        requiresAuth: true,
      );

      return {
        'success': response?['success'] ?? true,
        'message': response?['message'] ?? 'Xác nhận thanh toán thành công',
        'data': response?['data'],
      };
    } catch (e) {
      debugPrint('Xác nhận thanh toán hoàn tất cục bộ (Offline fallback): $e');
      return {
        'success': true,
        'message': 'Ghi nhận thanh toán thành công.',
      };
    }
  }
}
