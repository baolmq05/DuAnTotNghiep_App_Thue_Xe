import 'dart:async';
import 'dart:convert';
import 'package:duantotnghiep_app_thue_xe/services/websocket_service.dart';
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
  int? _chatbotSessionId;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get chatbotSessionId => _chatbotSessionId;

  final WebSocketService _webSocketService = WebSocketService();
  Conversation? _currentConversation;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  Future<void> loadMessagesForConversation(Conversation conversation) async {
    _isLoading = true;
    _errorMessage = null;
    _chatbotSessionId = null;
    notifyListeners();

    try {
      if (conversation.isChatbot) {
        final session = await _chatbotService.getChatbotSession();
        _messages.clear();

        if (session != null) {
          _chatbotSessionId = session.id;
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
        _currentConversation = conversation;
        final messageList = await _conversationService.getMessages(
          conversation.id,
          otherUserId: conversation.otherUser.id,
        );
        _messages.clear();
        _messages.addAll(messageList);

        // Mark messages as read in Backend
        await _conversationService.markAsRead(conversation.id);

        // Connect WebSocket and listen for real-time messages
        _webSocketService.connect();

        _wsSubscription?.cancel();
        _wsSubscription = _webSocketService.messageStream.listen((packet) {
          final event = packet['event'];
          final channel = packet['channel'];
          final targetChannel = 'private-chat.${conversation.id}';

          if (event == 'message.sent' && channel == targetChannel) {
            try {
              final payload = jsonDecode(packet['data'] as String);
              final messageJson = payload['message'];

              final senderIdInt = messageJson['sender_id'] is int
                  ? messageJson['sender_id']
                  : int.tryParse(messageJson['sender_id']?.toString() ?? '') ??
                        0;

              final bool isMe = senderIdInt != conversation.otherUser.id;

              final incomingMessage = ChatMessage(
                id:
                    messageJson['id']?.toString() ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: senderIdInt.toString(),
                text: messageJson['text']?.toString() ?? '',
                timestamp:
                    DateTime.tryParse(
                      messageJson['created_at']?.toString() ?? '',
                    ) ??
                    DateTime.now(),
                isMe: isMe,
              );

              // Filter duplicates
              final isDuplicate = _messages.any(
                (m) => m.id == incomingMessage.id,
              );
              if (!isDuplicate) {
                _messages.add(incomingMessage);
                notifyListeners(); // Redraw UI
              }
            } catch (e) {
              debugPrint('Failed to decode realtime message: $e');
            }
          }
        });

        // Subscribe to channel
        _webSocketService.subscribe('private-chat.${conversation.id}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> sendChatbotMessage({required String message}) async {
    try {
      _errorMessage = null;
      final responseText = await _chatbotService.sendChatbotMessage(
        message: message,
        conversationId: _chatbotSessionId?.toString(),
      );
      return responseText;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      _errorMessage = null;
      await _conversationService.sendMessage(
        conversationId: conversationId,
        text: text,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearConversation() {
    _currentConversation = null;
    _wsSubscription?.cancel();
    _messages.clear();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
