import 'dart:io';
import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/report_service.dart';
import 'package:duantotnghiep_app_thue_xe/models/report_model.dart';

class OrderDetailViewModel extends ChangeNotifier {
  OrderDetailViewModel({TripService? tripService, ReportService? reportService})
    : _tripService = tripService ?? TripService(),
      _reportService = reportService ?? ReportService();

  final TripService _tripService;
  final ReportService _reportService;

  TripModel? _trip;
  ReportModel? _report;
  bool _isLoading = true;
  String _errorMessage = '';

  TripModel? get trip => _trip;
  ReportModel? get report => _report;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchTripDetail(int orderId) async {
    _isLoading = true;
    _errorMessage = '';
    _report = null;
    notifyListeners();

    try {
      final trip = await _tripService.getTripDetail(orderId);
      _trip = trip;
      _report = trip?.report;

      debugPrint('[DEBUG] Đã gán báo cáo từ chi tiết chuyến đi: ${_report?.id}');
    } catch (e, stack) {
      debugPrint('[ERROR] Lỗi khi tải chi tiết chuyến đi: $e');
      debugPrint(stack.toString());
      try {
        File('error_log.txt').writeAsStringSync('Error: $e\n\n$stack');
      } catch (_) {}
      _errorMessage = 'Không thể tải chi tiết đơn hàng. Vui lòng thử lại!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Gửi yêu cầu gia hạn chuyến đi
  Future<Map<String, dynamic>> requestExtension({
    required int tripId,
    required String endDate,
    required int extendedDays,
    required double extensionAmount,
  }) async {
    try {
      final result = await _tripService.requestExtension(
        tripId,
        endDate: endDate,
        extendedDays: extendedDays,
        extensionAmount: extensionAmount,
      );
      if (result['success'] == true) {
        // Refresh trip detail after success
        await fetchTripDetail(tripId);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Xác nhận chuyến đi (Chủ xe duyệt đơn)
  Future<Map<String, dynamic>> confirmTrip(int tripId) async {
    try {
      final result = await _tripService.confirmTrip(tripId);
      if (result['success'] == true) {
        await fetchTripDetail(tripId);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Từ chối chuyến đi (Chủ xe từ chối đơn)
  Future<Map<String, dynamic>> rejectTrip(int tripId, {String? reason}) async {
    try {
      final result = await _tripService.rejectTrip(tripId, reason: reason);
      if (result['success'] == true) {
        await fetchTripDetail(tripId);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Thu hồi báo cáo/khiếu nại
  Future<Map<String, dynamic>> cancelReport(int reportId) async {
    try {
      final result = await _reportService.cancelReport(reportId);
      if (result['success'] == true) {
        if (_trip != null) {
          await fetchTripDetail(_trip!.id);
        }
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }
}
