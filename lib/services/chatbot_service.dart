import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';
import 'package:duantotnghiep_app_thue_xe/models/chatbot_session_model.dart';

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

  /// Gửi tin nhắn đến chatbot và nhận về câu trả lời từ AI
  Future<String?> sendChatbotMessage({
    required String message,
    String? conversationId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'message': message,
      };
      if (conversationId != null) {
        body['conversationId'] = conversationId;
      }

      final response = await store(
        'api/auth/chatbot',
        body: body,
        requiresAuth: true,
      );

      if (response is String) {
        return response;
      }
      return response?.toString();
    } catch (e) {
      rethrow;
    }
  }
}
