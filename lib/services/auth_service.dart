import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
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

  /// Cập nhật thông tin tài khoản (Họ tên, SĐT, Giới tính, Ngày sinh, Ảnh đại diện)
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    int? gender,
    String? dob,
    File? avatarFile,
    XFile? avatarXFile,
  }) async {
    String? avatarUrl;

    if (avatarFile != null || avatarXFile != null) {
      avatarUrl = await _uploadToCloudinary(avatarFile, avatarXFile);
    }

    final response = await update(
      'api/auth/profile',
      body: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (dob != null) 'DOB': dob,
        if (avatarUrl != null) 'avatar': avatarUrl,
      },
      requiresAuth: true,
    );
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  /// Tải ảnh lên Cloudinary trực tiếp
  Future<String> _uploadToCloudinary(File? file, XFile? xfile) async {
    const cloudName = 'djbobb5oe';
    const uploadPreset = 'Drivio';
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;

    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      throw Exception('Không tìm thấy file ảnh.');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return json['secure_url'] as String;
    } else {
      throw Exception('Lỗi upload ảnh lên Cloudinary: Mã ${response.statusCode}');
    }
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
