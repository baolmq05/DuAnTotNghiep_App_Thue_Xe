import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:duantotnghiep_app_thue_xe/models/user_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/auth_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/owner_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '675568821910-optermrfnul04rkmqdmt6kr44iolh3s5.apps.googleusercontent.com'
        : null,
    serverClientId: kIsWeb
        ? null
        : '675568821910-optermrfnul04rkmqdmt6kr44iolh3s5.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );
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
      await fetchProfile();
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

  /// Đăng nhập bằng Google
  Future<bool> loginWithGoogle([BuildContext? context]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // 1. Kích hoạt Popup Google Sign-In thật
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng huỷ chọn
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // 2. Lấy thông tin xác thực
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      String? token = googleAuth.idToken;

      // Fallback: Trên trình duyệt Web chạy local, đôi khi idToken bị null. 
      // Chúng ta lấy accessToken hoặc tự động tạo token dự phòng để gửi lên Backend.
      if (token == null || token.isEmpty) {
        token = googleAuth.accessToken;
        if (token == null || token.isEmpty) {
          token = 'web_fallback_token_${googleUser.id}';
        }
      }

      // 3. Gửi Token lên Backend để xác thực
      final res = await _authService.loginWithGoogle(
        email: googleUser.email,
        name: googleUser.displayName ?? 'Google User',
        idToken: token,
      );
      _token = res['access_token'] as String;
      await _authService.saveToken(_token!);
      await fetchProfile();
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

      await fetchProfile();

      // Nếu có số điện thoại, tiến hành cập nhật qua profile
      if (phone != null && phone.isNotEmpty) {
        try {
          await _authService.updateProfile(
            name: name,
            phone: phone,
          );
          await fetchProfile();
        } catch (_) {
          // Bỏ qua lỗi cập nhật sđt nếu đăng ký chính thành công
        }
      }

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
      await fetchProfile();
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

  /// Tải lại thông tin cá nhân (bao gồm cả số chuyến đi và số sao từ đánh giá)
  Future<void> fetchProfile() async {
    if (!isAuthenticated) return;
    try {
      final profileUser = await _authService.getProfile();
      int tripsCount = profileUser.tripsCount;
      double rating = profileUser.rating;

      // 1. Tải danh sách chuyến đi thực tế từ API my-trips
      try {
        final trips = await TripService().getMyTrips();
        if (trips.isNotEmpty) {
          final completed = trips.where((t) {
            final st = (t.statusText ?? '').toLowerCase();
            return t.status == 4 || st.contains('hoàn') || st.contains('thành') || st.contains('xong');
          }).length;

          if (completed > 0) {
            tripsCount = completed;
          } else {
            final activeOrDone = trips.where((t) => t.status != 5 && t.status != 6).length;
            tripsCount = activeOrDone > 0 ? activeOrDone : trips.length;
          }
        }
      } catch (e) {
        debugPrint('Lỗi fetch trips trong profile: $e');
      }

      // 2. Tải đánh giá thực tế (reviews) của tài khoản và tính trung bình cộng số sao
      try {
        final reviewData = await OwnerProfileService().fetchProfileReviews(
          targetId: profileUser.id,
          isOwner: false,
        );
        if (reviewData != null) {
          final List reviewsList = reviewData['reviews'] as List? ?? [];
          if (reviewsList.isNotEmpty) {
            double totalStars = 0.0;
            int validCount = 0;
            for (var r in reviewsList) {
              final rVal = double.tryParse(r['rating']?.toString() ?? r['stars']?.toString() ?? '') ?? 0.0;
              if (rVal > 0) {
                totalStars += rVal;
                validCount++;
              }
            }
            if (validCount > 0) {
              rating = totalStars / validCount;
            } else if (reviewData['rating'] != null) {
              rating = double.tryParse(reviewData['rating'].toString()) ?? 0.0;
            }
          } else if (reviewData['rating'] != null) {
            rating = double.tryParse(reviewData['rating'].toString()) ?? 0.0;
          }

          if (reviewData['trips_count'] != null) {
            final tc = int.tryParse(reviewData['trips_count'].toString()) ?? 0;
            if (tc > 0) tripsCount = tc;
          }
        }
      } catch (e) {
        debugPrint('Lỗi fetch reviews trong profile: $e');
      }

      _user = UserModel(
        id: profileUser.id,
        name: profileUser.name,
        email: profileUser.email,
        phone: profileUser.phone,
        avatar: profileUser.avatar,
        gender: profileUser.gender,
        dob: profileUser.dob,
        status: profileUser.status,
        roleId: profileUser.roleId,
        walletId: profileUser.walletId,
        drivingLicenseId: profileUser.drivingLicenseId,
        drivingLicense: profileUser.drivingLicense,
        tripsCount: tripsCount,
        rating: rating,
      );
      notifyListeners();
    } catch (_) {
      // Có lỗi thì giữ thông tin cũ hoặc xử lý sau
    }
  }

  /// Đổi mật khẩu
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      
      if (res['success'] == true) {
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Đổi mật khẩu thất bại.';
        return false;
      }
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
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
    return message
        .replaceAll('Exception: ', '')
        .replaceAll('ApiException:', '');
  }
}
