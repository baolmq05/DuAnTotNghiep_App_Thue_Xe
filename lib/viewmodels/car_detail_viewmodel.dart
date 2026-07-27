import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_detail_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';
import 'package:flutter/material.dart';

class CarDetailViewmodel extends ChangeNotifier {
  final CarService carService = CarService();
  final TripService tripService = TripService();

  Car_Detail? _carDetail;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasBooked = false;

  Car_Detail? get carDetail => _carDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasBooked => _hasBooked;

  Future<void> fetchCarDetail({required int id}) async {
    _isLoading = true;
    _errorMessage = null;
    _hasBooked = false;
    notifyListeners();

    try {
      _carDetail = await carService.getCarDetail(id: id);

      // Chỉ lấy chuyến đi của CHÍNH USER ĐANG ĐĂNG NHẬP để kiểm tra
      try {
        final trips = await tripService.getMyTrips();
        _hasBooked = trips.any((trip) =>
            trip.carId == id &&
            (trip.status == 0 ||
                trip.status == 1 ||
                trip.status == 2 ||
                trip.status == 3));
      } catch (e) {
        debugPrint('Lỗi kiểm tra trạng thái đặt xe của user: $e');
        _hasBooked = false;
      }

      debugPrint('=== FETCH CAR DETAIL SUCCESS ===');
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      debugPrint('=== FETCH CAR DETAIL ERROR ===');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

