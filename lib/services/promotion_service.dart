import '../models/promotion_model.dart';
import 'base_service.dart';

class PromotionService extends BaseService {
  Future<List<Promotion>> getPromotions() async {
    final response = await get('/api/promotions');

    final List data = response['data'];

    return data.map((e) => Promotion.fromJson(e)).toList();
  }
}
