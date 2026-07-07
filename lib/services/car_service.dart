import '../models/car_model.dart';
import 'base_service.dart';

class CarService extends BaseService {
  Future<List<Car>> getCars() async {
    final response = await get('/api/cars');

    final List data = response['data'];

    return data.map((e) => Car.fromJson(e)).toList();
  }
}
