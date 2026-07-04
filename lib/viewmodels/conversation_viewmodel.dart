import 'package:duantotnghiep_app_thue_xe/models/conversation.dart';
import 'package:duantotnghiep_app_thue_xe/models/chatbot_session.dart';
import 'package:duantotnghiep_app_thue_xe/services/conversation_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/chatbot_service.dart';
import 'package:flutter/material.dart';

class ConversationViewmodel extends ChangeNotifier {
  final ConversationService conversationService = ConversationService();
  final ChatbotService _chatbotService = ChatbotService();

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Gọi đồng thời danh sách cuộc hội thoại và thông tin chatbot từ API để gộp chung
  Future<void> fetchConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Phát sự kiện hiển thị loading

    try {
      // 1. Tải danh sách hội thoại thông thường của người dùng
      final List<Conversation> userConversations = await conversationService.getConversations();

      // 2. Tải thông tin phiên Chatbot từ API
      Conversation? chatbotConv;
      try {
        final ChatbotSession? chatbotSession = await _chatbotService.getChatbotSession();
        if (chatbotSession != null) {
          chatbotConv = Conversation.raw(
            id: chatbotSession.id.toString(), // Ví dụ: "19"
            status: 1,
            createdAt: chatbotSession.createdAt,
            updatedAt: chatbotSession.updatedAt,
            otherUser: OtherUser(
              id: chatbotSession.userId,
              name: chatbotSession.title, // "Trợ lý AI"
              avatar: 'lib/assets/images/drivio_logo.png', // Avatar mặc định của Drivio
            ),
            unreadCount: 0,
            lastMessageObj: LastMessage(
              text: chatbotSession.messages.isNotEmpty 
                  ? chatbotSession.messages.last['text']?.toString() ?? ''
                  : 'Bấm vào để trò chuyện với Trợ lý AI.',
              type: 'text',
              sender_id: 0,
              created_at: chatbotSession.updatedAt,
            ),
          );
        }
      } catch (chatbotError) {
        // Bắt lỗi riêng của Chatbot để không làm crash màn hình tin nhắn thông thường
        debugPrint('Lỗi tải Chatbot API: $chatbotError');
      }

      // 3. Gộp chatbot vào đầu danh sách hội thoại
      _conversations = [];
      if (chatbotConv != null) {
        _conversations.add(chatbotConv);
      }
      
      // Lọc bỏ trùng lặp nếu trong danh sách hội thoại thường đã có ID này
      for (var conv in userConversations) {
        if (chatbotConv == null || conv.id != chatbotConv.id) {
          _conversations.add(conv);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Cập nhật lại UI
    }
  }
}
