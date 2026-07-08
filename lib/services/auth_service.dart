import 'package:duantotnghiep_app_thue_xe/models/user_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class AuthService extends BaseService {
  /// Đăng nhập hệ thống
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await store('api/auth/login', body: {
      'email': email,
      'password': password,
    });
    return response as Map<String, dynamic>;
  }

  /// Đăng nhập bằng tài khoản Google
  Future<Map<String, dynamic>> loginWithGoogle({
    String? idToken,
    String? accessToken,
    String? email,
    String? name,
  }) async {
    final Map<String, dynamic> body = {};
    if (idToken != null) {
      body['id_token'] = idToken;
      body['token'] = idToken;
    }
    if (accessToken != null) body['access_token'] = accessToken;
    if (email != null) body['email'] = email;
    if (name != null) body['name'] = name;

    final response = await store('api/auth/google', body: body);
    return response as Map<String, dynamic>;
  }

  /// Đăng ký tài khoản mới
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await store('api/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    });
    return response as Map<String, dynamic>;
  }

  /// Lấy thông tin tài khoản hiện tại
  Future<UserModel> getProfile() async {
    final response = await get('api/auth/profile', requiresAuth: true);
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  /// Cập nhật thông tin tài khoản (ví dụ: cập nhật số điện thoại sau đăng ký)
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
  }) async {
    final response = await update(
      'api/auth/profile',
      body: {
        'name': name,
        'phone': phone,
      },
      requiresAuth: true,
    );
    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }

  /// Đổi mật khẩu tài khoản
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await store(
      'api/auth/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
      requiresAuth: true,
    );
    return response as Map<String, dynamic>;
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> logout() async {
    try {
      await store('api/auth/logout', requiresAuth: true);
    } catch (_) {
      // Bỏ qua lỗi khi gọi API logout hoặc token hết hạn
    } finally {
      await deleteToken();
    }
  }
}
