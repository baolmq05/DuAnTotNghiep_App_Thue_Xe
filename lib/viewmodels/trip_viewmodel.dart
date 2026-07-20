import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';

class TripViewModel extends ChangeNotifier {
  TripViewModel({TripService? tripService})
    : _tripService = tripService ?? TripService();

  final TripService _tripService;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// API Gọi gửi yêu cầu đặt xe mới
  Future<bool> bookingCar(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Thông báo cho UI biết đang trong trạng thái loading

    try {
      final result = await _tripService.createTrip(bookingData);

      _isLoading = false;
      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
       // Nếu thất bại, cập nhật thông báo lỗi và thông báo cho UI
        _errorMessage =
            result['message'] ?? 'Đặt xe thất bại. Vui lòng thử lại!';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!';
      notifyListeners();
      return false;
    }
  }
}
