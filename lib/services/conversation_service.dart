import 'dart:convert';

import 'package:duantotnghiep_app_thue_xe/models/conversation.dart';
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
}
