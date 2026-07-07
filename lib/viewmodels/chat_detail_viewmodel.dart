import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/chat_message_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/conversation_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/chatbot_service.dart';

class ChatDetailViewModel extends ChangeNotifier {
  ChatDetailViewModel({
    ConversationService? conversationService,
    ChatbotService? chatbotService,
  }) : _conversationService = conversationService ?? ConversationService(),
       _chatbotService = chatbotService ?? ChatbotService();

  final ConversationService _conversationService;
  final ChatbotService _chatbotService;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMessagesForConversation(Conversation conversation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (conversation.isChatbot) {
        final session = await _chatbotService.getChatbotSession();
        _messages.clear();

        if (session != null) {
          for (final item in session.messages) {
            final message = ChatMessage(
              id: item.id.toString(),
              senderId: item.role == 'user' ? 'me' : 'chatbot',
              text: item.content,
              timestamp: DateTime.tryParse(item.created_at) ?? DateTime.now(),
              isMe: item.role == 'user',
            );
            _messages.add(message);
          }
        }
      } else {
        final messageList = await _conversationService.getMessages(
          conversation.id,
          otherUserId: conversation.otherUser.id,
        );
        _messages.clear();
        _messages.addAll(messageList);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
