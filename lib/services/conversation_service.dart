import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/chat_message_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class ConversationService extends BaseService {
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await get('api/conversations', requiresAuth: true);

      if (response is Map && response['conversations'] is List) {
        return (response['conversations'] as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get messages by conversation ID
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int? otherUserId,
  }) async {
    try {
      final response = await get(
        'api/messages/$conversationId',
        requiresAuth: true,
      );

      List<dynamic> messageList = [];
      if (response is List) {
        messageList = response;
      } else if (response is Map) {
        if (response['messages'] is List) {
          messageList = response['messages'];
        } else if (response['data'] is List) {
          messageList = response['data'];
        }
      }

      return messageList.map((json) {
        final int senderIdInt = json['sender_id'] is int
            ? json['sender_id']
            : int.tryParse(json['sender_id']?.toString() ?? '') ?? 0;

        // Check if message is from self
        bool isMe = json['is_me'] == true || json['is_me'] == 1;
        if (json['is_me'] == null && otherUserId != null) {
          isMe = senderIdInt != otherUserId;
        }

        return ChatMessage(
          id:
              json['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: senderIdInt.toString(),
          text: json['text']?.toString() ?? json['content']?.toString() ?? '',
          timestamp:
              DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
          isMe: isMe,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Send message
  Future<ChatMessage?> sendMessage({
    required String conversationId,
    required String text,
    String type = 'text',
  }) async {
    try {
      final response = await store(
        'api/messages',
        body: {
          'conversation_id': conversationId,
          'text': text,
          'type': type,
        },
        requiresAuth: true,
      );

      if (response is Map && response['success'] == true && response['message'] != null) {
        final json = response['message'];
        final int senderIdInt = json['sender_id'] is int
            ? json['sender_id']
            : int.tryParse(json['sender_id']?.toString() ?? '') ?? 0;

        return ChatMessage(
          id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: senderIdInt.toString(),
          text: json['text']?.toString() ?? '',
          timestamp: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
          isMe: true,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Mark conversation as read
  Future<bool> markAsRead(String conversationId) async {
    try {
      final response = await update(
        'api/conversations/$conversationId/read',
        requiresAuth: true,
      );
      if (response is Map && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
