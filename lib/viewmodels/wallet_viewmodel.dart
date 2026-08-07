import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/services/wallet_service.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService _service = WalletService();

  double _balance = 0.0;
  double _holdBalance = 0.0;
  double _pendingBalance = 0.0;
  List<dynamic> _transactions = [];
  List<dynamic> _refunds = [];
  Map<String, dynamic> _summary = {};

  bool _isLoading = false;
  String? _errorMessage;

  double get balance => _balance;
  double get holdBalance => _holdBalance;
  double get pendingBalance => _pendingBalance;
  List<dynamic> get transactions => _transactions;
  List<dynamic> get refunds => _refunds;
  Map<String, dynamic> get summary => _summary;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy thông tin ví và lịch sử giao dịch
  Future<void> fetchWalletDetails({int? month, int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchWalletDetails(month: month, year: year);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _balance = double.tryParse(data['balance']?.toString() ?? '') ?? 0.0;
        _holdBalance = double.tryParse(data['hold_balance']?.toString() ?? '') ?? 0.0;
        _pendingBalance = double.tryParse(data['pending_balance']?.toString() ?? '') ?? 0.0;
        _transactions = data['transactions'] as List<dynamic>? ?? [];
        _refunds = data['refunds'] as List<dynamic>? ?? [];
        _summary = data['summary'] as Map<String, dynamic>? ?? {};
        _errorMessage = null;
      } else {
        _errorMessage = response['message'] ?? 'Không thể lấy thông tin ví.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException:', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gửi yêu cầu rút tiền
  Future<Map<String, dynamic>> withdraw(int amount, String? description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.withdraw(amount, description);
      if (response['success'] == true) {
        // Cập nhật lại số tiền khả dụng trả về từ server
        if (response['balance'] != null) {
          _balance = double.tryParse(response['balance'].toString()) ?? _balance;
        }
        // Gọi lại fetch để đồng bộ lịch sử giao dịch mới
        await fetchWalletDetails();
        return {
          'success': true,
          'message': response['message'] ?? 'Gửi yêu cầu rút tiền thành công.',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Rút tiền thất bại.',
        };
      }
    } catch (e) {
      final errMsg = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException:', '');
      return {
        'success': false,
        'message': errMsg,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
