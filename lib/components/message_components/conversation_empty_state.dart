import 'package:flutter/material.dart';

class ConversationEmptyState extends StatelessWidget {
  final bool isCompleted;

  const ConversationEmptyState({
    super.key,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
            isCompleted
                ? 'Không có cuộc hội thoại nào hoàn thành'
                : 'Không tìm thấy cuộc hội thoại nào',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
