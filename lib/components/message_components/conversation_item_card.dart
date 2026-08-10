import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/conversation_model.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class ConversationItemCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationItemCard({
    super.key,
    required this.conversation,
    required this.onTap,
  });

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

  Widget _buildPlaceholderAvatar(BuildContext context) {
    if (conversation.isChatbot) {
      return Center(
        child: Text(
          'D',
          style: TextStyle(
            color: context.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      );
    }

    final colors = _getGradientColors(conversation.name);
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

  Widget _buildAvatar(BuildContext context) {
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
                    _buildPlaceholderAvatar(context),
              )
            : Image.asset(
                conversation.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderAvatar(context),
              ),
      );
    } else {
      avatarWidget = _buildPlaceholderAvatar(context);
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: conversation.isChatbot
            ? context.primaryColor.withValues(alpha: 0.08)
            : null,
        border: Border.all(
          color: conversation.isChatbot
              ? context.primaryColor.withValues(alpha: 0.2)
              : Colors.grey.shade100,
          width: 1.5,
        ),
      ),
      child: avatarWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 14.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(context),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 15.5,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: conversation.unreadCount > 0
                                ? context.textPrimary
                                : context.textSecondary,
                            fontSize: 14,
                            height: 1.3,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(
                            left: 10,
                          ),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${conversation.unreadCount}',
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
  }
}
