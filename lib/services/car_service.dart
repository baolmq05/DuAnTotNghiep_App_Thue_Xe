import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';

import '../models/car_model.dart';
import 'base_service.dart';

class CarService extends BaseService {
  Future<List<Car>> getCars() async {
    final response = await get('/api/cars');

    final List data = response['data'];

    return data.map((e) => Car.fromJson(e)).toList();
  }

  Future<Car_Detail> getCarDetail({required int id}) async {
    final response = await get('/api/cars/6');

    print('=== CAR DETAIL RAW RESPONSE ===');
    print(response);
    print('=== CAR DETAIL DATA ===');
    print(response['data']);

    final Car_Detail data = Car_Detail.fromJson(response['data']);

    return data;
  }
}
