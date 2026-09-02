import '../models/promotion_model.dart';
import 'base_service.dart';

class PromotionService extends BaseService {
  Future<List<Promotion>> getPromotions() async {
    final response = await get('/api/promotions');

    final dynamic data = response['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Promotion.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> checkPromotion({
    required String code,
    required String startAt,
    required String endAt,
    required int carId,
    required double deliveryFee,
  }) async {
    final response = await store(
      '/api/promotions/check',
      body: {
        'code': code,
        'start_at': startAt,
        'end_at': endAt,
        'car_id': carId,
        'delivery_fee': deliveryFee,
      },
      requiresAuth: true,
    );
    return response['data'] ?? {};
  }
}
