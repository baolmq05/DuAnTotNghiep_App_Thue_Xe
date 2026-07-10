import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

/// Lỗi phát sinh khi đi gọi API gặp chuyện.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  ApiException({required this.message, this.statusCode, this.body});

  @override
  String toString() => 'ApiException(Mã: $statusCode, Lỗi: $message)';
}

abstract class BaseService {
  String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Lấy cái Token ra xài (mốt gắn storage sau).
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Lấy token đã lưu ngoài bộ nhớ (nếu có).
  Future<String?> getSavedToken() => _getToken();

  /// Lưu token vào storage để xài lâu dài.
  Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('auth_token', token);
  }

  /// Xoá token khỏi storage khi đăng xuất.
  Future<bool> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('auth_token');
  }

  /// Tạo tiêu đề (Headers) gửi kèm, có đòi token thì nhét vô luôn.
  Future<Map<String, String>> _getHeaders({
    Map<String, String>? customHeaders,
    bool requiresAuth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (customHeaders != null) headers.addAll(customHeaders);
    return headers;
  }

  /// Ráp link gốc với cái đường đi cho ra cái địa chỉ chuẩn.
  Uri _buildUri(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$baseUrl$cleanEndpoint');
  }

  /// Coi kết quả server trả về ngon hay bị lỗi thì xử lý liền.
  dynamic _processResponse(http.Response response) {
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    String errorMsg = 'Server báo lỗi mã $status nha!';
    try {
      final json = jsonDecode(response.body);
      if (json is Map) {
        if (json.containsKey('message') && json.containsKey('errors')) {
          errorMsg = "${json['message']} (${json['errors']})";
        } else if (json.containsKey('message')) {
          errorMsg = json['message'];
        } else if (json.containsKey('errors')) {
          errorMsg = json['errors']?.toString() ?? '';
        }
      }
    } catch (_) {}

    throw ApiException(
      message: errorMsg,
      statusCode: status,
      body: response.body,
    );
  }

  /// Hàm trung gian chạy đi gửi đơn (request) và nhận kết quả về.
  Future<dynamic> _sendRequest(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final reqHeaders = await _getHeaders(
        customHeaders: headers,
        requiresAuth: requiresAuth,
      );
      final encodedBody = body is Map || body is List ? jsonEncode(body) : body;

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: reqHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: reqHeaders,
            body: encodedBody,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: reqHeaders,
            body: encodedBody,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: reqHeaders,
            body: encodedBody,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: reqHeaders);
          break;
        default:
          throw Exception('Method gì lạ hoắc vậy nè: $method');
      }

      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Gọi cái $method bị lỗi rồi: $e');
    }
  }

  // Get
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) {
    return _sendRequest(
      'GET',
      endpoint,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Create
  Future<dynamic> store(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) {
    return _sendRequest(
      'POST',
      endpoint,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Update
  Future<dynamic> update(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) {
    return _sendRequest(
      'PUT',
      endpoint,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Delete
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) {
    return _sendRequest(
      'DELETE',
      endpoint,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> uploadMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    dynamic xfile,
    String fileField = 'image',
    bool requiresAuth = false,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // MultipartRequest tự thêm Content-Type, nên xóa đi để tránh lỗi.
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(headers); // Thêm tiêu đề vào request

      request.fields.addAll(fields); // Thêm các trường dữ liệu vào request

      if (xfile != null) {
        // XFile có thể từ web hoặc mobile
        final bytes = await xfile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            bytes,
            filename: 'image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else if (file != null) {
        if (kIsWeb) {
          // web đọc bytes từ file rồi gửi lên
          final bytes = await file.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              fileField,
              bytes,
              filename: 'image.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else {
          // mobile đọc từ đường dẫn file
          request.files.add(
            await http.MultipartFile.fromPath(
              fileField,
              file.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: 'Upload Multipart lỗi: $e');
    }
  }
}
