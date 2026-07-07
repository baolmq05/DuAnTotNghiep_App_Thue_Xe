import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';

class OrderViewModel extends ChangeNotifier {
  OrderViewModel({TripService? tripService})
    : _tripService = tripService ?? TripService();

  final TripService _tripService;

  final List<TripModel> _allTrips = [];
  final List<TripModel> _filteredTrips = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<TripModel> get allTrips => _allTrips;
  List<TripModel> get filteredTrips => _filteredTrips;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchTrips() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final trips = await _tripService.getMyTrips();
      _allTrips.clear();
      _allTrips.addAll(trips);
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Không thể tải danh sách đơn hàng. Vui lòng thử lại!';
      notifyListeners();
    }
  }

  void filterTrips(int tabIndex) {
    _filteredTrips.clear();

    if (tabIndex == 0) {
      _filteredTrips.addAll(_allTrips);
      notifyListeners();
      return;
    }

    final targetStatus = _getStatusForTab(tabIndex);
    final listStatus = _getMultiStatusForTab(tabIndex);

    if (listStatus.isNotEmpty) {
      for (final trip in _allTrips) {
        if (listStatus.contains(trip.status)) {
          _filteredTrips.add(trip);
        }
      }
    } else {
      for (final trip in _allTrips) {
        if (trip.status == targetStatus) {
          _filteredTrips.add(trip);
        }
      }
    }

    notifyListeners();
  }

  int _getStatusForTab(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 0;
      case 2:
        return 1;
      case 4:
        return 4;
      case 5:
        return 6;
      case 6:
        return 5;
      default:
        return 0;
    }
  }

  List<int> _getMultiStatusForTab(int tabIndex) {
    if (tabIndex == 3) {
      return [2, 3];
    }
    return [];
  }
}
