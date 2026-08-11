import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';

class OwnerOrderDetailViewModel extends ChangeNotifier {
  OwnerOrderDetailViewModel({TripService? tripService})
    : _tripService = tripService ?? TripService();

  final TripService _tripService;

  TripModel? _trip;
  bool _isLoading = true;
  String _errorMessage = '';

  TripModel? get trip => _trip;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchTripDetail(int orderId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final trip = await _tripService.getTripDetail(orderId);
      _trip = trip;
      if (_trip == null) {
        _errorMessage = 'Không tìm thấy đơn thuê xe.';
      }
    } catch (_) {
      _errorMessage = 'Không thể tải chi tiết đơn thuê xe. Vui lòng thử lại!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
