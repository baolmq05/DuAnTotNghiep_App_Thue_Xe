import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:flutter/material.dart';

class CarDetailViewmodel extends ChangeNotifier {
  final CarService carService = CarService();

  Car_Detail? _carDetail;
  bool _isLoading = false;
  String? _errorMessage;

  Car_Detail? get carDetail => _carDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCarDetail({required int id}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _carDetail = await carService.getCarDetail(id: id);
      print('=== FETCH CAR DETAIL SUCCESS ===');
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      print('=== FETCH CAR DETAIL ERROR ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
