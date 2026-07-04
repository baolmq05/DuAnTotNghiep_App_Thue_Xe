import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/user_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Đăng nhập
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.login(email, password);
      _token = res['access_token'] as String;
      await _authService.saveToken(_token!);
      _user = UserModel.fromJson(res['user'] as Map<String, dynamic>);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng ký
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      final tokenInfo = res['token_info'] as Map<String, dynamic>;
      _token = tokenInfo['access_token'] as String;
      await _authService.saveToken(_token!);

      UserModel registeredUser = UserModel.fromJson(res['user'] as Map<String, dynamic>);

      // Nếu có số điện thoại, tiến hành cập nhật qua profile
      if (phone != null && phone.isNotEmpty) {
        try {
          registeredUser = await _authService.updateProfile(name: name, phone: phone);
        } catch (_) {
          // Bỏ qua lỗi cập nhật sđt nếu đăng ký chính thành công
        }
      }

      _user = registeredUser;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tự động đăng nhập từ token đã lưu
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    _errorMessage = null;
    // Báo load nhẹ lúc splash
    try {
      final savedToken = await _authService.getSavedToken();
      if (savedToken == null || savedToken.isEmpty) {
        return false;
      }

      _token = savedToken;
      // Lấy thông tin cá nhân từ server để xác thực token hợp lệ
      _user = await _authService.getProfile();
      _errorMessage = null;
      return true;
    } catch (_) {
      // Lỗi xảy ra (hết hạn token hoặc không mạng), xoá token và yêu cầu đăng nhập lại
      await _authService.deleteToken();
      _token = null;
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải lại thông tin cá nhân
  Future<void> fetchProfile() async {
    if (!isAuthenticated) return;
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (_) {
      // Có lỗi thì giữ thông tin cũ hoặc xử lý sau
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (_) {
      // Bỏ qua lỗi
    } finally {
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm sạch thông báo lỗi để hiển thị thân thiện
  String _cleanErrorMessage(String message) {
    if (message.contains('ApiException')) {
      // Lấy phần lỗi thực sự từ ApiException(Mã: xxx, Lỗi: YYY)
      final regExp = RegExp(r'Lỗi:\s*(.*)\)$');
      final match = regExp.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)!;
      }
    }
    return message.replaceAll('Exception: ', '').replaceAll('ApiException:', '');
  }
}
