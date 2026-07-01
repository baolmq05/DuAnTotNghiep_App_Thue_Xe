import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/models/message_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({super.key});

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; 

  final List<Conversation> _allConversations = [
    Conversation(
      id: 'chatbot',
      name: 'Hỗ trợ Drivio',
      avatarUrl: 'lib/assets/images/drivio_logo.png',
      lastMessage: 'Chúng tôi sẽ hỗ trợ bạn trong thời gian sớm nhất.',
      time: '2 ngày trước',
      isChatbot: true,
      isOnline: true,
    ),
    Conversation(
      id: 'duc',
      name: 'Nguyễn Minh Đức',
      avatarUrl: 'lib/assets/images/avatar_duc.png',
      lastMessage: 'Chào bạn, mình đã xem lịch và có thể giao xe vào lúc 9h nhé.',
      time: '09:30',
      attachmentImageUrl: 'lib/assets/images/car_white.png',
      unreadCount: 2,
      isOnline: true,
    ),
    Conversation(
      id: 'huy',
      name: 'Phạm Gia Huy',
      avatarUrl: 'lib/assets/images/avatar_huy.png',
      lastMessage: 'Bạn gửi mình thêm ảnh nội thất xe được không?',
      time: 'Hôm qua',
      attachmentImageUrl: 'lib/assets/images/scooter_grey.png',
      unreadCount: 1,
    ),
  ];

  List<Conversation> get _filteredConversations {
    var list = _allConversations.where((c) {
      final nameMatch = c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final msgMatch = c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || msgMatch;
    }).toList();

    if (_filterType == 'unread') {
      list = list.where((c) => c.unreadCount > 0).toList();
    } else if (_filterType == 'chatbot') {
      list = list.where((c) => c.isChatbot).toList();
    }

    final chatbots = list.where((c) => c.isChatbot).toList();
    final others = list.where((c) => !c.isChatbot).toList();

    return [...chatbots, ...others];
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

  Widget _buildAvatar(Conversation conversation) {
    if (conversation.isChatbot) {
      return Stack(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                conversation.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (conversation.isOnline)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      );
    }

    final colors = _getGradientColors(conversation.name);
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
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
              conversation.name.split(' ').last[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        if (conversation.isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttachment(String? path) {
    if (path == null) return const SizedBox.shrink();

    IconData icon = Icons.directions_car_filled_outlined;
    Color iconColor = AppColors.primary;
    if (path.contains('scooter')) {
      icon = Icons.two_wheeler_outlined;
      iconColor = AppColors.secondary;
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 58,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.12), width: 0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon, color: iconColor.withOpacity(0.4), size: 22),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Lọc tin nhắn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.message,
                  color: _filterType == 'all' ? AppColors.primary : Colors.grey,
                ),
                title: const Text('Tất cả tin nhắn'),
                trailing: _filterType == 'all'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _filterType = 'all');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.mark_chat_unread,
                  color: _filterType == 'unread' ? AppColors.primary : Colors.grey,
                ),
                title: const Text('Chưa đọc'),
                trailing: _filterType == 'unread'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _filterType = 'unread');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.smart_toy,
                  color: _filterType == 'chatbot' ? AppColors.primary : Colors.grey,
                ),
                title: const Text('Hỗ trợ Drivio (Chatbot)'),
                trailing: _filterType == 'chatbot'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _filterType = 'chatbot');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredConversations;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 15.0),
              child: const Text(
                'Tin nhắn',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm tin nhắn',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9CA3AF),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterMenu,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.tune,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            if (_filterType != 'all')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _filterType == 'unread' ? 'Đang lọc: Chưa đọc' : 'Đang lọc: Chatbot',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() => _filterType = 'all');
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: AppColors.primary,
                          size: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ),

            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy tin nhắn nào',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0xFFF3F4F6),
                        height: 1,
                        indent: 84,
                        endIndent: 20,
                      ),
                      itemBuilder: (context, index) {
                        final conv = list[index];

                        return InkWell(
                          onTap: () {
                            context.push('/chat/${conv.id}', extra: conv);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAvatar(conv),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              conv.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: conv.unreadCount > 0
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            conv.time,
                                            style: TextStyle(
                                              color: conv.unreadCount > 0
                                                  ? AppColors.primary
                                                  : const Color(0xFF9CA3AF),
                                              fontSize: 12,
                                              fontWeight: conv.unreadCount > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              conv.lastMessage,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: conv.unreadCount > 0
                                                    ? Colors.black87
                                                    : const Color(0xFF6B7280),
                                                fontSize: 14.5,
                                                height: 1.3,
                                                fontWeight: conv.unreadCount > 0
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          _buildAttachment(
                                              conv.attachmentImageUrl),
                                          if (conv.unreadCount > 0)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              width: 22,
                                              height: 22,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${conv.unreadCount}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
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
        ),
      ),
    );
  }
}
