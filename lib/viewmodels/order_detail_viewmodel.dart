import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';

class OrderDetailViewModel extends ChangeNotifier {
  OrderDetailViewModel({TripService? tripService})
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
    } catch (_) {
      _errorMessage = 'Không thể tải chi tiết đơn hàng. Vui lòng thử lại!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
