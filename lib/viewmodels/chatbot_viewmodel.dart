import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/chatbot_session.dart';
import 'package:duantotnghiep_app_thue_xe/services/chatbot_service.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotService _service = ChatbotService();

  ChatbotSession? _chatbotSession;
  bool _isLoading = false;
  String? _errorMessage;

  ChatbotSession? get chatbotSession => _chatbotSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy thông tin phiên trò chuyện Chatbot từ API
  Future<void> fetchChatbotSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _chatbotSession = await _service.getChatbotSession();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
