import '../models/notification_model.dart';
import 'base_service.dart';

class NotificationService extends BaseService {
  // Lấy danh sách thông báo từ API theo user_id
  Future<List<Notification>> fetchNotifications() async {
    try {
      // Gọi API để lấy danh sách thông báo và token tự động được thêm vào header bởi BaseService
      final response = await get( 
        'api/auth/notifications',
        requiresAuth: true, 
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
        body: {
          'is_read': '1', 
        },
        requiresAuth: true, 
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
        requiresAuth: true, 
      );
    } catch (e) {
      print('LỖI KHI XÓA THÔNG BÁO: $e');
      rethrow;
    }
  }
}