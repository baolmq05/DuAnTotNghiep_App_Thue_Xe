import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';

class ConversationsView extends StatefulWidget {
  const ConversationsView({super.key});

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationViewmodel>().fetchConversations();
    });
  }

  /// Filters the conversation list based on the search query and active filter type
  List<Conversation> filteredConversations(
    List<Conversation> allConversations,
  ) {
    final List<Conversation> results = [];

    // STEP 1: Loop through each conversation to check search and filter criteria
    for (var conversation in allConversations) {
      final String userName = conversation.name.toLowerCase();
      final String lastMessageText = conversation.lastMessage.toLowerCase();
      final String searchQuery = _searchQuery.toLowerCase();

      // 1. Check search match (Username or Last message)
      final bool isSearchMatch =
          userName.contains(searchQuery) ||
          lastMessageText.contains(searchQuery);

      // 2. Check filter match (Unread / Chatbot)
      bool isFilterMatch = true;
      if (_filterType == 'unread') {
        isFilterMatch = conversation.unreadCount > 0;
      } else if (_filterType == 'chatbot') {
        isFilterMatch = conversation.isChatbot;
      }

      // 3. Add to results if both search and filter match
      if (isSearchMatch && isFilterMatch) {
        results.add(conversation);
      }
    }

    // STEP 2: Sort the results (prioritize chatbots to the top)
    results.sort((a, b) {
      if (a.isChatbot && !b.isChatbot) return -1;
      if (!a.isChatbot && b.isChatbot) return 1;
      return 0;
    });

    return results;
  }

  Widget _buildAvatar(Conversation conversation) {
    final bool hasAvatar =
        conversation.avatarUrl.isNotEmpty &&
        (conversation.avatarUrl.startsWith('http') ||
            conversation.avatarUrl.startsWith('assets') ||
            conversation.avatarUrl.startsWith('lib'));

    Widget avatarWidget;
    if (hasAvatar) {
      final bool isNetwork = conversation.avatarUrl.startsWith('http');
      avatarWidget = ClipOval(
        child: isNetwork
            ? Image.network(
                conversation.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderAvatar(conversation),
              )
            : Image.asset(
                conversation.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderAvatar(conversation),
              ),
      );
    } else {
      avatarWidget = _buildPlaceholderAvatar(conversation);
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: conversation.isChatbot
            ? AppColors.primary.withOpacity(0.08)
            : null,
        border: Border.all(
          color: conversation.isChatbot
              ? AppColors.primary.withOpacity(0.2)
              : Colors.grey.shade100,
          width: 1.5,
        ),
      ),
      child: avatarWidget,
    );
  }

  Widget _buildPlaceholderAvatar(Conversation conversation) {
    if (conversation.isChatbot) {
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
    }

    final colors = _getGradientColors(conversation.name);
    // Lấy chữ cái đầu tiên của Tên (Ví dụ: "Bảo Lê" -> "B")
    final String initialLetter = conversation.name.isNotEmpty
        ? conversation.name[0].toUpperCase()
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
            fontSize: 18,
          ),
        ),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  color: _filterType == 'unread'
                      ? AppColors.primary
                      : Colors.grey,
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
                  color: _filterType == 'chatbot'
                      ? AppColors.primary
                      : Colors.grey,
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

  List<Color> _getGradientColors(String name) {
    final hash = name.hashCode;
    final List<List<Color>> palettes = [
      [const Color(0xFF6366F1), const Color(0xFF4F46E5)], // Indigo
      [const Color(0xFFEC4899), const Color(0xFFD946EF)], // Pink/Fuchsia
      [const Color(0xFF14B8A6), const Color(0xFF0D9488)], // Teal
      [const Color(0xFFF59E0B), const Color(0xFFEAB308)], // Yellow/Amber
      [const Color(0xFF0EA5E9), const Color(0xFF2563EB)], // Light Blue/Blue
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald
    ];
    return palettes[hash.abs() % palettes.length];
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 4,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFFF3F4F6),
        height: 1,
        indent: 86,
        endIndent: 20,
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Circle Placeholder
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 110,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
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
    final viewModel = context.watch<ConversationViewmodel>();
    final list = filteredConversations(viewModel.conversations);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 20.0,
                bottom: 15.0,
              ),
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
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
                        child: Icon(Icons.tune, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            if (_filterType != 'all')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 5.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _filterType == 'unread'
                            ? 'Đang lọc: Chưa đọc'
                            : 'Đang lọc: Chatbot',
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
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: viewModel.isLoading
                  ? _buildSkeletonLoader()
                  : viewModel.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: 40,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Không thể kết nối danh sách',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 130,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () => viewModel.fetchConversations(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Tải lại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy cuộc hội thoại nào',
                            style: TextStyle(
                              color: Colors.grey.shade400,
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
                        indent: 86,
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
                              vertical: 14.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAvatar(conv),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                color: Colors.black87,
                                                fontSize: 15.5,
                                                fontWeight: conv.unreadCount > 0
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                              ),
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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: conv.unreadCount > 0
                                                    ? Colors.black87
                                                    : const Color(0xFF6B7280),
                                                fontSize: 14,
                                                height: 1.3,
                                                fontWeight: conv.unreadCount > 0
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),

                                          if (conv.unreadCount > 0)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 10,
                                              ),
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${conv.unreadCount}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
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
