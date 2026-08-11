import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';

class OwnerOrderViewModel extends ChangeNotifier {
  OwnerOrderViewModel({TripService? tripService})
      : _tripService = tripService ?? TripService();

  final TripService _tripService;

  final List<TripModel> _allTrips = [];
  final List<TripModel> _filteredTrips = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentTabIndex = 0;

  List<TripModel> get allTrips => _allTrips;
  List<TripModel> get filteredTrips => _filteredTrips;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get currentTabIndex => _currentTabIndex;

  /// Đếm số lượng đơn hàng theo từng Tab index
  int getCountForTab(int tabIndex) {
    if (tabIndex == 0) return _allTrips.length;
    final targetStatus = _getStatusForTab(tabIndex);
    return _allTrips.where((trip) => trip.status == targetStatus).length;
  }

  Future<void> fetchOwnerTrips() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final trips = await _tripService.getOwnerTrips();

      final enrichedTrips = await Future.wait(trips.map((trip) async {
        try {
          final detail = await _tripService.getTripDetail(trip.id);
          if (detail != null && detail.car != null) {
            return detail;
          }
        } catch (e) {
          debugPrint('Lỗi fetch detail cho trip ${trip.id}: $e');
        }
        return trip;
      }));

      _allTrips.clear();
      _allTrips.addAll(enrichedTrips);
      _isLoading = false;
      filterTrips(_currentTabIndex);
    } catch (e) {
      debugPrint('Lỗi fetchOwnerTrips: $e');
      _isLoading = false;
      _errorMessage = 'Không thể tải danh sách đơn thuê xe. Vui lòng thử lại!';
      notifyListeners();
    }
  }

  void filterTrips(int tabIndex) {
    _currentTabIndex = tabIndex;
    _filteredTrips.clear();

    if (tabIndex == 0) {
      _filteredTrips.addAll(_allTrips);
      notifyListeners();
      return;
    }

    final targetStatus = _getStatusForTab(tabIndex);
    for (final trip in _allTrips) {
      if (trip.status == targetStatus) {
        _filteredTrips.add(trip);
      }
    }

    notifyListeners();
  }

  int _getStatusForTab(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 0; // Chờ duyệt
      case 2:
        return 1; // Chờ thanh toán
      case 3:
        return 2; // Đã xác nhận / Đã cọc
      case 4:
        return 3; // Đang di chuyển
      case 5:
        return 4; // Hoàn tất
      case 6:
        return 6; // Chủ xe hủy
      case 7:
        return 5; // Người thuê hủy
      case 8:
        return 8; // Chờ trả xe
      default:
        return 0;
    }
  }
}
