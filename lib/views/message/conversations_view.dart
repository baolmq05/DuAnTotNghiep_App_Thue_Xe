import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/conversation_viewmodel.dart';

// Components
import 'package:duantotnghiep_app_thue_xe/components/message_components/conversation_item_card.dart';
import 'package:duantotnghiep_app_thue_xe/components/message_components/conversation_skeleton.dart';
import 'package:duantotnghiep_app_thue_xe/components/message_components/conversation_empty_state.dart';
import 'package:duantotnghiep_app_thue_xe/components/message_components/conversation_error_state.dart';
import 'package:duantotnghiep_app_thue_xe/components/message_components/conversation_filter_sheet.dart';

class ConversationsView extends StatefulWidget {
  const ConversationsView({super.key});

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // 3 filters: 'all', 'unread', 'chatbot'

  @override
  void initState() {
    super.initState();
    // Get conversations when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationViewmodel>().fetchConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter and sort conversations by search query and filter type
  List<Conversation> _filterAndSortConversations(
    List<Conversation> originalList,
  ) {
    final query = _searchQuery.toLowerCase();

    var filtered = originalList.where((conv) {
      final nameMatch = conv.name.toLowerCase().contains(query);
      final lastMsgMatch = conv.displayLastMessage.toLowerCase().contains(query) ||
          conv.lastMessage.toLowerCase().contains(query);
      final searchMatch = nameMatch || lastMsgMatch;

      if (_filterType == 'unread') {
        return searchMatch && conv.unreadCount > 0;
      } else if (_filterType == 'chatbot') {
        return searchMatch && conv.isChatbot;
      }
      return searchMatch;
    }).toList();

    // Sort to show chatbot at the top
    filtered.sort((a, b) {
      if (a.isChatbot && !b.isChatbot) return -1;
      if (!a.isChatbot && b.isChatbot) return 1;
      return 0;
    });

    return filtered;
  }

  // Show conversation list for each Tab (Active or Completed)
  Widget _buildConversationTabList(
    ConversationViewmodel viewModel, {
    required bool isCompleted,
  }) {
    // 1. Separate list by status (0 = Completed, other = Active)
    final tabConversations = viewModel.conversations.where((conv) {
      return isCompleted ? (conv.status == 0) : (conv.status != 0);
    }).toList();

    // 2. Filter and sort by search text and filter menu
    final displayList = _filterAndSortConversations(tabConversations);

    // 3. Handle loading, error, or empty list
    if (viewModel.isLoading) {
      return const ConversationSkeleton();
    }
    if (viewModel.errorMessage != null) {
      return ConversationErrorState(
        errorMessage: viewModel.errorMessage!,
        onRetry: () => viewModel.fetchConversations(),
      );
    }
    if (displayList.isEmpty) {
      return ConversationEmptyState(isCompleted: isCompleted);
    }

    // 4. Show the main list
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: displayList.length,
      separatorBuilder: (context, index) =>
          Divider(color: context.border, height: 1, indent: 86, endIndent: 20),
      itemBuilder: (context, index) {
        final conv = displayList[index];

        return ConversationItemCard(
          conversation: conv,
          onTap: () async {
            context.read<ConversationViewmodel>().markAsReadLocally(conv.id);
            await context.push('/chat/${conv.id}', extra: conv);
            if (mounted) {
              context.read<ConversationViewmodel>().fetchConversations();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConversationViewmodel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: context.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 20.0,
          title: Text(
            'Tin nhắn',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar and Filter button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
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
                          fillColor: context.inputBackground,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.border, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.border, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: context.primaryColor, width: 1.5),
                          ),
                        ),
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => ConversationFilterSheet(
                            currentFilterType: _filterType,
                            onFilterChanged: (type) {
                              setState(() => _filterType = type);
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.border, width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.tune,
                            color: context.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Tab bar for Active and Completed tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: context.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'Đang'),
                      Tab(text: 'Hoàn thành'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Show active filter name
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
                      color: context.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _filterType == 'unread'
                              ? 'Đang lọc: Chưa đọc'
                              : 'Đang lọc: Chatbot',
                          style: TextStyle(
                            color: context.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() => _filterType = 'all');
                          },
                          child: Icon(
                            Icons.cancel,
                            color: context.primaryColor,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // List of conversations for selected tab
              Expanded(
                child: TabBarView(
                  children: [
                    _buildConversationTabList(viewModel, isCompleted: false),
                    _buildConversationTabList(viewModel, isCompleted: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
