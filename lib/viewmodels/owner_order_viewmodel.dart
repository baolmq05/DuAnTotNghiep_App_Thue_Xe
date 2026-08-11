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

  static const List<String> tabTitles = [
    'Tất cả',
    'Chờ duyệt',
    'Chờ thanh toán',
    'Đã xác nhận',
    'Đang di chuyển',
    'Hoàn tất',
    'Chủ xe hủy',
    'Người thuê hủy',
    'Chờ trả xe',
  ];

  List<int> getStatusCodesForTab(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return [0];
      case 2:
        return [1];
      case 3:
        return [2];
      case 4:
        return [3];
      case 5:
        return [4];
      case 6:
        return [6];
      case 7:
        return [5];
      case 8:
        return [7, 8];
      case 0:
      default:
        return const [];
    }
  }

  int getCountForTrips(List<TripModel> trips, int tabIndex) {
    if (tabIndex == 0) return trips.length;
    final statuses = getStatusCodesForTab(tabIndex);
    if (statuses.isEmpty) return 0;
    return trips.where((trip) => statuses.contains(trip.status)).length;
  }

  int getCountForTab(int tabIndex) {
    return getCountForTrips(_allTrips, tabIndex);
  }

  Future<void> fetchOwnerTrips() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final trips = await _tripService.getOwnerTrips();

      final enrichedTrips = await Future.wait(
        trips.map((trip) async {
          try {
            final detail = await _tripService.getTripDetail(trip.id);
            if (detail != null && detail.car != null) {
              return detail;
            }
          } catch (e) {
            debugPrint('Lỗi fetch detail cho trip ${trip.id}: $e');
          }
          return trip;
        }),
      );

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

    final statuses = getStatusCodesForTab(tabIndex);
    if (statuses.isEmpty) {
      notifyListeners();
      return;
    }

    for (final trip in _allTrips) {
      if (statuses.contains(trip.status)) {
        _filteredTrips.add(trip);
      }
    }

    notifyListeners();
  }
}
