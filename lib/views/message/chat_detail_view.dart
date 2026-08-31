import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:duantotnghiep_app_thue_xe/models/chat_message_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chatbot_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/chat_detail_viewmodel.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';

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
  final ImagePicker _picker = ImagePicker();
  late Conversation _conv;
  bool _isTyping = false;
  int _messageCount = 0;

  void _pickAndSendImage(ImageSource source) async {
    if (!_conv.isChatbot && _conv.status == 0) return;
    final errorColor = context.error;
    final chatDetailViewModel = context.read<ChatDetailViewModel>();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final newMsg = ChatMessage(
          id: tempId,
          senderId: 'me',
          text: '',
          timestamp: DateTime.now(),
          isMe: true,
          imageUrl: image.path,
        );
        setState(() {
          chatDetailViewModel.messages.add(newMsg);
        });
        _scrollToBottom();

        // Simulating chatbot or backend response
        if (_conv.isChatbot) {
          setState(() {
            _isTyping = true;
          });
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              final botMsg = ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: 'chatbot',
                text:
                    'Tôi đã nhận được ảnh của bạn. Tôi có thể giúp gì thêm không?',
                timestamp: DateTime.now(),
                isMe: false,
              );
              setState(() {
                chatDetailViewModel.messages.add(botMsg);
                _isTyping = false;
              });
              _scrollToBottom();
            }
          });
        } else {
          try {
            await chatDetailViewModel.sendImageMessage(
              conversationId: _conv.id,
              imageFile: image,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi gửi hình ảnh: $e'),
                  backgroundColor: errorColor,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                chatDetailViewModel.messages.removeWhere((m) => m.id == tempId);
              });
              _scrollToBottom();
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở máy ảnh/thư viện: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _conv =
        widget.conversation ??
        Conversation(
          id: widget.conversationId,
          name: widget.conversationId.startsWith('chatbot')
              ? 'Hỗ trợ Drivio'
              : 'Người dùng',
          avatarUrl: widget.conversationId.startsWith('chatbot')
              ? 'lib/assets/images/drivio_logo.png'
              : 'lib/assets/images/default-avatar.jpg',
          lastMessage: '',
          time: 'Vừa xong',
          isChatbot: widget.conversationId.startsWith('chatbot'),
          isOnline: true,
        );

    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.conversation == null && !widget.conversationId.startsWith('chatbot')) {
        try {
          final convVm = context.read<ConversationViewmodel>();
          // Kiểm tra trong danh sách cuộc trò chuyện hiện có
          final matches = convVm.conversations.where((c) => c.id == widget.conversationId);
          if (matches.isNotEmpty) {
            _conv = matches.first;
          } else {
            // Nếu danh sách chưa có, tải lại từ API
            await convVm.fetchConversations();
            final updatedMatches = convVm.conversations.where((c) => c.id == widget.conversationId);
            if (updatedMatches.isNotEmpty) {
              _conv = updatedMatches.first;
            }
          }
        } catch (e) {
          debugPrint('Lỗi tải thông tin cuộc trò chuyện: $e');
        }
      }

      final chatDetailViewModel = context.read<ChatDetailViewModel>();
      await chatDetailViewModel.loadMessagesForConversation(_conv);
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    });
  }

  void _sendMessage() async {
    if (!_conv.isChatbot && _conv.status == 0) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final chatDetailViewModel = context.read<ChatDetailViewModel>();

    if (_conv.isChatbot) {
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        text: text,
        timestamp: DateTime.now(),
        isMe: true,
      );

      // Chatbot
      setState(() {
        chatDetailViewModel.messages.add(userMsg);
        _isTyping = true;
      });
      _scrollToBottom();

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

        // If the session ID was previously null (first message sent), reload the session
        // to retrieve and bind the backend-generated session ID.
        if (chatDetailViewModel.chatbotSessionId == null) {
          await chatDetailViewModel.loadMessagesForConversation(_conv);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chatbot error: $e'),
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
      try {
        await chatDetailViewModel.sendMessage(
          conversationId: _conv.id,
          text: text,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi gửi tin nhắn: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
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
          color: context.primaryColor.withValues(alpha: 0.08),
          border: Border.all(
            color: context.primaryColor.withValues(alpha: 0.2),
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
                    color: context.primaryColor,
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

    final bool hasAvatar =
        _conv.avatarUrl.isNotEmpty &&
        (_conv.avatarUrl.startsWith('http') ||
            _conv.avatarUrl.startsWith('assets') ||
            _conv.avatarUrl.startsWith('lib'));

    Widget avatarWidget;
    if (hasAvatar) {
      final bool isNetwork = _conv.avatarUrl.startsWith('http');
      avatarWidget = ClipOval(
        child: isNetwork
            ? Image.network(
                _conv.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderAvatar(),
              )
            : Image.asset(
                _conv.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderAvatar(),
              ),
      );
    } else {
      avatarWidget = _buildPlaceholderAvatar();
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
      ),
      child: avatarWidget,
    );
  }

  Widget _buildPlaceholderAvatar() {
    final colors = _getGradientColors(_conv.name);
    final String initialLetter = _conv.name.isNotEmpty
        ? _conv.name.split(' ').last[0].toUpperCase()
        : '?';

    return Container(
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
          initialLetter,
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

    // Auto scroll to bottom when new messages arrive
    if (messages.length > _messageCount) {
      _messageCount = messages.length;
      _scrollToBottom();
    } else if (messages.length < _messageCount) {
      _messageCount = messages.length;
    }

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.5,
        shadowColor: Colors.black12,
        backgroundColor: context.scaffoldBackgroundColor,
        leadingWidth: 44,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: context.textPrimary,
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
                style: TextStyle(
                  color: context.textPrimary,
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
          // IconButton(
          //   icon: Icon(Icons.info_outline, color: context.textSecondary),
          //   onPressed: () {},
          // ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _conv.isChatbot && context.watch<ChatbotViewModel>().isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
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
                                  color: context.chatBubbleIncoming,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SizedBox(
                                  width: 30,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      context.primaryColor,
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

          !_conv.isChatbot && _conv.status == 0
              ? Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 30,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    border: Border(
                      top: BorderSide(color: context.border, width: 0.8),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: context.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Cuộc trò chuyện đã đóng',
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Chuyến đi đã kết thúc hoặc đã hủy. Bạn chỉ có thể xem lại lịch sử tin nhắn.',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 10,
                    bottom: 25,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!_conv.isChatbot) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                          onPressed: () =>
                              _pickAndSendImage(ImageSource.gallery),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                          onPressed: () =>
                              _pickAndSendImage(ImageSource.camera),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onSubmitted: (_) => _sendMessage(),
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 15,
                            ),
                            fillColor: context.inputBackground,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: context.border,
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: context.border,
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: context.primaryColor,
                                width: 1.2,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
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
    // Thử phân tích cú pháp dữ liệu gợi ý xe (JSON hoặc Markdown)
    final carSuggestionsData = !msg.isMe
        ? _tryParseCarSuggestions(msg.text)
        : null;

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
                child: carSuggestionsData != null
                    ? _buildCarSuggestions(carSuggestionsData)
                    : msg.imageUrl != null
                    ? GestureDetector(
                        onTap: () => _viewImageFull(context, msg.imageUrl!),
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 220,
                            maxHeight: 220,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                msg.imageUrl!.startsWith('http') || kIsWeb
                                    ? Image.network(
                                        msg.imageUrl!,
                                        fit: BoxFit.cover,
                                        width: 220,
                                        height: 220,
                                      )
                                    : Image.file(
                                        File(msg.imageUrl!),
                                        fit: BoxFit.cover,
                                        width: 220,
                                        height: 220,
                                      ),
                                if (msg.id.startsWith('temp_'))
                                  Container(
                                    color: Colors.black38,
                                    width: 220,
                                    height: 220,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isMe
                              ? context.primaryColor
                              : context.chatBubbleIncoming,
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
                            color: msg.isMe
                                ? Colors.white
                                : context.textPrimary,
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

  Widget _buildCarSuggestions(Map<String, dynamic> data) {
    final message =
        data['message']?.toString() ?? 'Dưới đây là một số gợi ý xe cho bạn:';
    final carsList = data['cars'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bong bóng hiển thị thông điệp văn bản từ AI
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.chatBubbleIncoming,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ),
        if (carsList.isNotEmpty) ...[
          const SizedBox(height: 10),
          // Danh sách xe cuộn ngang cực kỳ mượt mà
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: carsList.length,
              itemBuilder: (context, index) {
                final car = carsList[index] as Map<String, dynamic>;
                final carId = car['id'] as int? ?? 0;
                final carName = car['name']?.toString() ?? 'Xe Drivio';
                final thumbnail = car['thumbnail']?.toString() ?? '';
                final price = car['price'] is num
                    ? (car['price'] as num).toInt()
                    : 0;
                final originalPrice = car['original_price'] is num
                    ? (car['original_price'] as num).toInt()
                    : 0;
                final location = car['location']?.toString() ?? '';
                final owner = car['owner']?.toString() ?? '';
                final features =
                    (car['features'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [];

                final hasDiscount = originalPrice > price;

                return GestureDetector(
                  onTap: () => context.push('/car_detail/$carId'),
                  child: Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 12, bottom: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.border, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // CỘT 1: HÌNH ẢNH XE (Bên trái, full chiều cao card)
                        SizedBox(
                          width: 105,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildCarThumbnailWidget(thumbnail),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // CỘT 2: THÔNG TIN CHI TIẾT XE (Bên phải)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    carName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Chủ xe: $owner',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Dòng Badge: 3 tính năng nổi bật (car_features)
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: [
                                      for (var feature in features.take(3))
                                        _buildMiniBadge(
                                          context,
                                          feature.trim(),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Địa chỉ xe
                                  if (location.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 11,
                                          color: context.textSecondary,
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: context.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  // Giá thuê xe & Nút đặt
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 4,
                                          children: [
                                            Text(
                                              '${_formatCurrency(price)}/ngày',
                                              style: TextStyle(
                                                color: context.primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (hasDiscount)
                                              Text(
                                                _formatCurrency(originalPrice),
                                                style: TextStyle(
                                                  color: context.textSecondary,
                                                  fontSize: 10,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Thuê ngay',
                                        style: TextStyle(
                                          color: context.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCarThumbnailWidget(String thumbnail) {
    if (thumbnail.isNotEmpty &&
        (thumbnail.startsWith('http://') ||
            thumbnail.startsWith('https://') ||
            thumbnail.startsWith('assets') ||
            thumbnail.startsWith('lib/'))) {
      if (thumbnail.startsWith('http://') || thumbnail.startsWith('https://')) {
        return Image.network(
          thumbnail,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildCarPlaceholderImage(),
        );
      } else {
        return Image.asset(
          thumbnail,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildCarPlaceholderImage(),
        );
      }
    }
    return _buildCarPlaceholderImage();
  }

  Widget _buildCarPlaceholderImage() {
    return Image.network(
      'https://img1.oto.com.vn/2024/01/18/toyota-wigo-2023-ts4-7d9b-429a_wm.webp',
      width: 85,
      height: 85,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 85,
        height: 85,
        color: context.primaryColor.withValues(alpha: 0.08),
        child: Center(
          child: Icon(
            Icons.directions_car_filled_rounded,
            color: context.primaryColor,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.border, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return format.format(value).replaceAll('₫', 'đ');
  }

  Map<String, dynamic>? _tryParseCarSuggestions(String text) {
    if (text.trim().isEmpty) return null;
    final cleaned = text.trim();

    // 1. Thử parse dạng JSON (trực tiếp hoặc nằm trong ```json ... ```)
    try {
      String jsonStr = cleaned;
      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json').last.split('```').first.trim();
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```')[1].trim();
      }

      final startIdx = jsonStr.indexOf('{');
      final endIdx = jsonStr.lastIndexOf('}');
      if (startIdx != -1 && endIdx > startIdx) {
        final candidate = jsonStr.substring(startIdx, endIdx + 1);
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic> && decoded.containsKey('cars')) {
          return decoded;
        }
      }
    } catch (_) {}

    // 2. Thử parse dạng Markdown (cho các tin nhắn văn bản từ AI chứa danh sách xe)
    if (cleaned.contains('vehicles/') ||
        cleaned.contains('Chi tiết:') ||
        cleaned.contains('Giá thuê:')) {
      try {
        final List<Map<String, dynamic>> cars = [];
        final lines = cleaned.split('\n');
        String introMessage = 'Dưới đây là các xe phù hợp với yêu cầu của bạn:';

        for (var line in lines) {
          final t = line.trim();
          if (t.isNotEmpty && !t.startsWith('**') && !t.startsWith('-')) {
            introMessage = t;
            break;
          }
        }

        // Tách theo mẫu **1. hoặc các khối danh sách xe
        final carBlocks = cleaned.split(RegExp(r'\n(?=\*\*\d+\.)'));
        for (var block in carBlocks) {
          final nameMatch = RegExp(r'\*\*\d+\.\s*(.*?)\*\*').firstMatch(block);
          final idMatch = RegExp(r'vehicles\/(\d+)').firstMatch(block);

          if (nameMatch != null || idMatch != null) {
            final name = nameMatch?.group(1)?.trim() ?? 'Xe Drivio';
            final carId = int.tryParse(idMatch?.group(1) ?? '0') ?? 0;

            final ownerMatch = RegExp(
              r'-\s*\*\*Chủ xe:\*\*\s*(.*)',
            ).firstMatch(block);
            final priceMatch = RegExp(
              r'-\s*\*\*Giá thuê:\*\*\s*([\d\.]+)',
            ).firstMatch(block);
            final origPriceMatch = RegExp(
              r'-\s*\*\*Giá gốc:\*\*\s*~~([\d\.]+)',
            ).firstMatch(block);

            final owner = ownerMatch?.group(1)?.trim() ?? '';
            final priceStr = priceMatch?.group(1)?.replaceAll('.', '') ?? '0';
            final origPriceStr =
                origPriceMatch?.group(1)?.replaceAll('.', '') ?? '0';

            final price = int.tryParse(priceStr) ?? 0;
            final origPrice = int.tryParse(origPriceStr) ?? price;

            cars.add({
              'id': carId,
              'name': name,
              'owner': owner,
              'price': price,
              'original_price': origPrice,
              'thumbnail':
                  'https://img1.oto.com.vn/2024/01/18/toyota-wigo-2023-ts4-7d9b-429a_wm.webp',
              'location': '',
            });
          }
        }

        if (cars.isNotEmpty) {
          return {'status': 'success', 'message': introMessage, 'cars': cars};
        }
      } catch (_) {}
    }

    return null;
  }

  void _viewImageFull(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: imageUrl.startsWith('http') || kIsWeb
                  ? Image.network(imageUrl, fit: BoxFit.contain)
                  : Image.file(File(imageUrl), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
