import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/models/chat_message_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chatbot_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chat_detail_viewmodel.dart';

class ChatDetailView extends StatefulWidget {
  final String conversationId;
  final Conversation? conversation;

  const ChatDetailView({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Conversation _conv;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _conv =
        widget.conversation ??
        Conversation(
          id: widget.conversationId,
          name: widget.conversationId == 'chatbot'
              ? 'Hỗ trợ Drivio'
              : 'Người dùng',
          avatarUrl: widget.conversationId == 'chatbot'
              ? 'lib/assets/images/drivio_logo.png'
              : 'lib/assets/images/avatar_duc.png',
          lastMessage: '',
          time: 'Vừa xong',
          isChatbot: widget.conversationId == 'chatbot',
          isOnline: true,
        );

    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatDetailViewModel = context.read<ChatDetailViewModel>();
      await chatDetailViewModel.loadMessagesForConversation(_conv);
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    });
  }
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    final chatDetailViewModel = context.read<ChatDetailViewModel>();
    
    // Thêm tin nhắn của người dùng vào giao diện trước để hiển thị tức thì
    setState(() {
      chatDetailViewModel.messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    if (_conv.isChatbot) {
      try {
        final replyText = await chatDetailViewModel.sendChatbotMessage(
          message: text,
        );

        if (replyText != null && replyText.isNotEmpty) {
          final botMsg = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'chatbot',
            text: replyText,
            timestamp: DateTime.now(),
            isMe: false,
          );
          chatDetailViewModel.messages.add(botMsg);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi gửi tin nhắn chatbot: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          _scrollToBottom();
        }
      }
    } else {
      // Logic giả lập phản hồi cho tin nhắn thường (nếu chưa có API)
      Timer(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
        });
        chatDetailViewModel.messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: _conv.id,
            text: 'Dạ vâng, cảm ơn bạn đã phản hồi nhanh chóng! 😊',
            timestamp: DateTime.now(),
            isMe: false,
          ),
        );
        if (mounted) setState(() {});
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<Color> _getGradientColors(String name) {
    final hash = name.hashCode;
    final List<List<Color>> palettes = [
      [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      [const Color(0xFF10B981), const Color(0xFF047857)],
      [const Color(0xFFF59E0B), const Color(0xFFB45309)],
      [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      [const Color(0xFFEC4899), const Color(0xFFBE185D)],
      [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
    ];
    return palettes[hash.abs() % palettes.length];
  }

  Widget _buildAvatar() {
    if (_conv.isChatbot) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            _conv.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'D',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    final colors = _getGradientColors(_conv.name);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _conv.name.split(' ').last[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatDetailViewModel = context.watch<ChatDetailViewModel>();
    final messages = chatDetailViewModel.messages;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        shadowColor: Colors.black12,
        backgroundColor: Colors.white,
        leadingWidth: 44,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        title: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _conv.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.phone_outlined, color: Colors.black54),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black54),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _conv.isChatbot && context.watch<ChatbotViewModel>().isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20.0,
                    ),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && _isTyping) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAvatar(),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const SizedBox(
                                  width: 30,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                    minHeight: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final msg = messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: 25,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF9CA3AF),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF9CA3AF),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),

                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.send, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: msg.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: msg.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!msg.isMe) ...[_buildAvatar(), const SizedBox(width: 8)],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isMe
                        ? AppColors.primary
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: msg.isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: msg.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4.0,
              left: msg.isMe ? 0 : 50.0,
              right: msg.isMe ? 8.0 : 0,
            ),
            child: Text(
              _formatTime(msg.timestamp),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
