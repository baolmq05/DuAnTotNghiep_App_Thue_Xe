import 'dart:async';
import 'dart:convert';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/chatbot_session_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/conversation_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/chatbot_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/websocket_service.dart';
import 'package:flutter/material.dart';

class ConversationViewmodel extends ChangeNotifier {
  final ConversationService conversationService = ConversationService();
  final ChatbotService _chatbotService = ChatbotService();

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch conversations from API and merge with chatbot session
  Future<void> fetchConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Conversation> userConversations = await conversationService.getConversations();

      Conversation? chatbotConv;
      try {
        final ChatbotSession? chatbotSession = await _chatbotService.getChatbotSession();
        if (chatbotSession != null) {
          chatbotConv = Conversation.raw(
            id: chatbotSession.id.toString(),
            status: 1,
            createdAt: chatbotSession.createdAt,
            updatedAt: chatbotSession.updatedAt,
            otherUser: OtherUser(
              id: chatbotSession.userId,
              name: chatbotSession.title,
              avatar: 'lib/assets/images/drivio_logo.png',
            ),
            unreadCount: 0,
            lastMessageObj: LastMessage(
              text: chatbotSession.messages.isNotEmpty
                  ? chatbotSession.messages.last.content
                  : 'Bấm vào để trò chuyện với Trợ lý AI.',
              type: 'text',
              sender_id: 0,
              created_at: chatbotSession.updatedAt,
            ),
          );
        }
      } catch (chatbotError) {
        debugPrint('Lỗi tải Chatbot API: $chatbotError');
      }

      _conversations = [];
      if (chatbotConv != null) {
        _conversations.add(chatbotConv);
      }

      for (var conv in userConversations) {
        if (chatbotConv == null || conv.id != chatbotConv.id) {
          _conversations.add(conv);
        }
      }

      // Connect to WebSocket and listen for real-time list updates
      final ws = WebSocketService();
      ws.connect();

      _wsSubscription?.cancel();
      _wsSubscription = ws.messageStream.listen((packet) {
        final event = packet['event'];
        final channel = packet['channel'];

        if (event == 'message.sent' && channel != null) {
          try {
            final payload = jsonDecode(packet['data'] as String);
            final messageJson = payload['message'];
            final String conversationId = messageJson['conversation_id']?.toString() ?? '';

            if (channel == 'private-chat.$conversationId') {
              _handleIncomingRealtimeMessage(conversationId, messageJson);
            }
          } catch (e) {
            debugPrint('Error updating conversation list: $e');
          }
        }
      });

      // Subscribe to all private channels
      for (var conv in _conversations) {
        if (!conv.isChatbot) {
          ws.subscribe('private-chat.${conv.id}');
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleIncomingRealtimeMessage(String conversationId, Map<String, dynamic> messageJson) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = _conversations[index];

      final text = messageJson['text']?.toString() ?? '';
      final type = messageJson['type']?.toString() ?? 'text';
      final senderId = messageJson['sender_id'] is int
          ? messageJson['sender_id']
          : int.tryParse(messageJson['sender_id']?.toString() ?? '') ?? 0;
      final createdAt = messageJson['created_at']?.toString() ?? '';

      final lastMsg = LastMessage(
        text: text,
        type: type,
        sender_id: senderId,
        created_at: createdAt,
      );

      final int newUnreadCount = conv.unreadCount + ((senderId == conv.otherUser.id) ? 1 : 0);

      final updatedConv = Conversation.raw(
        id: conv.id,
        status: conv.status,
        tripId: conv.tripId,
        createdAt: conv.createdAt,
        updatedAt: createdAt,
        otherUser: conv.otherUser,
        car: conv.car,
        lastMessageObj: lastMsg,
        unreadCount: newUnreadCount,
      );

      _conversations.removeAt(index);
      
      int insertIndex = 0;
      if (_conversations.isNotEmpty && _conversations[0].isChatbot) {
        insertIndex = 1;
      }
      _conversations.insert(insertIndex, updatedConv);
      notifyListeners();
    }
  }

  void markAsReadLocally(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = _conversations[index];
      _conversations[index] = Conversation.raw(
        id: conv.id,
        status: conv.status,
        tripId: conv.tripId,
        createdAt: conv.createdAt,
        updatedAt: conv.updatedAt,
        otherUser: conv.otherUser,
        car: conv.car,
        lastMessageObj: conv.lastMessageObj,
        unreadCount: 0,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
