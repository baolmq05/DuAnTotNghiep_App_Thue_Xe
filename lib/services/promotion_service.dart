import '../models/promotion_model.dart';
import 'base_service.dart';

class PromotionService extends BaseService {
  Future<List<Promotion>> getPromotions() async {
    final response = await get('/api/promotions');

    final List data = response['data'];

    return data.map((e) => Promotion.fromJson(e)).toList();
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
    return response['data'];
  }
}
