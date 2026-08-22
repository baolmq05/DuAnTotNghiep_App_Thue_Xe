import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/owner_report_summary_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/owner_service.dart';

class OwnerOrderViewModel extends ChangeNotifier {
  OwnerOrderViewModel({
    TripService? tripService,
    OwnerProfileService? ownerService,
  })  : _tripService = tripService ?? TripService(),
        _ownerService = ownerService ?? OwnerProfileService() {
    // Khởi tạo giá trị mặc định để giao diện Strike hiển thị ngay lập tức
    _reportSummary = OwnerReportSummaryModel.initial();
  }

  final TripService _tripService;
  final OwnerProfileService _ownerService;

  final List<TripModel> _allTrips = [];
  final List<TripModel> _filteredTrips = [];
  OwnerReportSummaryModel? _reportSummary;
  bool _isLoading = true;
  bool _isLoadingSummary = false;
  String _errorMessage = '';
  int _currentTabIndex = 0;

  List<TripModel> get allTrips => _allTrips;
  List<TripModel> get filteredTrips => _filteredTrips;
  OwnerReportSummaryModel? get reportSummary => _reportSummary;
  bool get isLoading => _isLoading;
  bool get isLoadingSummary => _isLoadingSummary;
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

  /// Tải dữ liệu toàn diện cho Bảng điều khiển chủ xe (Trips + Strike Summary)
  Future<void> fetchDashboardData() async {
    await Future.wait([
      fetchOwnerTrips(),
      fetchOwnerReportSummary(),
    ]);
  }

  /// Tải thông tin Strike / Báo cáo kỷ luật của chủ xe
  Future<void> fetchOwnerReportSummary() async {
    _isLoadingSummary = true;
    notifyListeners();

    try {
      debugPrint('[OwnerOrderViewModel] Bắt đầu gọi fetchOwnerReportSummary()...');
      final summary = await _ownerService.fetchOwnerReportSummary();
      if (summary != null) {
        _reportSummary = summary;
        debugPrint('[OwnerOrderViewModel] Đã gán reportSummary thành công: activeStrikes=${summary.activeStrikes}, total=${summary.totalStrikes}, reports=${summary.reports.total}');
      } else {
        debugPrint('[OwnerOrderViewModel] summary trả về null, giữ fallback initial.');
        _reportSummary ??= OwnerReportSummaryModel.initial();
      }
    } catch (e) {
      debugPrint('[OwnerOrderViewModel] Lỗi fetchOwnerReportSummary: $e');
      _reportSummary ??= OwnerReportSummaryModel.initial();
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  /// Tải danh sách các đơn cho thuê xe của chủ xe
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
