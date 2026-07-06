import '../models/notification_model.dart';
import 'base_service.dart';

class NotificationService extends BaseService {
  Map<String, String> _authHeaders() {
    const yourJwtToken =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvYXBpL2F1dGgvcmVmcmVzaCIsImlhdCI6MTc4MzMwNjkxNiwiZXhwIjoxNzgzMzE1Mjg5LCJuYmYiOjE3ODMzMTE2ODksImp0aSI6IjF0VGwycDVNekxwbVNyQk8iLCJzdWIiOiI4IiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.a4cuH19Z2IrgACYHqa0Q-oswzFoRznQ99a4ehoCRaec";

    return {'Authorization': 'Bearer $yourJwtToken'};
  }

  // Lấy danh sách thông báo từ API
  Future<List<Notification>> fetchNotifications() async {
    try {
      final response = await get(
        'api/auth/notifications?user_id=8',
        headers: _authHeaders(),
      );

      print('DỮ LIỆU TỪ LARAVEL TRẢ VỀ: $response');
      if (response != null && response is List) {
        return response.map((json) => Notification.fromJson(json)).toList();
      }
      if (response != null && response is Map && response.containsKey('data')) {
        List<dynamic> dataList = response['data'];
        return dataList.map((json) => Notification.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('LỖI KHI PARSE MODEL NOTIFICATION: $e');
      rethrow;
    }
  }

  // Cập nhật trạng thái đã đọc của thông báo
  Future<void> markAsRead(Notification notification) async {
    try {
      await update(
        'api/auth/notifications/${notification.id}',
        body: {'is_read': '1'},
        headers: _authHeaders(),
      );
    } catch (e) {
      print('LỖI KHI CẬP NHẬT THÔNG BÁO ĐÃ ĐỌC: $e');
      rethrow;
    }
  }

// Xóa thông báo
  Future<void> deleteNotification(Notification notification) async {
    try {
      await delete(
        'api/auth/notifications/${notification.id}',
        headers: _authHeaders(),
      );
    } catch (e) {
      print('LỖI KHI XÓA THÔNG BÁO: $e');
      rethrow;
    }
  }
}
