import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_brand_model.dart';

import '../models/car_model.dart';
import 'base_service.dart';

class CarService extends BaseService {
  Future<List<CarBrand>> getCarBrands() async {
    final response = await get('/api/car-brands');
    final List data = response['data'];
    return data.map((e) => CarBrand.fromJson(e)).toList();
  }

  Future<List<Car>> getCars({Map<String, String>? queryParameters}) async {
    final endpoint = '/api/cars';
    final response = queryParameters == null || queryParameters.isEmpty
        ? await get(endpoint)
        : await get(
            Uri(path: endpoint, queryParameters: queryParameters).toString(),
          );

    final List data = response['data'];

    return data.map((e) => Car.fromJson(e)).toList();
  }

  Future<Car_Detail> getCarDetail({required int id}) async {
    final response = await get('/api/cars/$id');

    print('=== CAR DETAIL RAW RESPONSE ===');
    print(response);
    print('=== CAR DETAIL DATA ===');
    print(response['data']);

    final Car_Detail data = Car_Detail.fromJson(response['data']);

    return data;
  }
}
