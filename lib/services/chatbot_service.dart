import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';
import 'package:duantotnghiep_app_thue_xe/models/chatbot_session.dart';

class ChatbotService extends BaseService {
  
  /// Gọi API lấy thông tin cuộc trò chuyện chatbot của người dùng hiện tại
  Future<ChatbotSession?> getChatbotSession() async {
    try {
      final response = await get('api/auth/chatbot', requiresAuth: true);

      if (response is Map && response['res'] != null) {
        return ChatbotSession.fromJson(response['res']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
