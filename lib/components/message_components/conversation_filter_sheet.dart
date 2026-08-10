import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/themes/app_colors.dart';

class ConversationFilterSheet extends StatelessWidget {
  final String currentFilterType;
  final ValueChanged<String> onFilterChanged;

  const ConversationFilterSheet({
    super.key,
    required this.currentFilterType,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              color: currentFilterType == 'all'
                  ? context.primaryColor
                  : Colors.grey,
            ),
            title: const Text('Tất cả tin nhắn'),
            trailing: currentFilterType == 'all'
                ? Icon(Icons.check, color: context.primaryColor)
                : null,
            onTap: () {
              onFilterChanged('all');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.mark_chat_unread,
              color: currentFilterType == 'unread'
                  ? context.primaryColor
                  : Colors.grey,
            ),
            title: const Text('Chưa đọc'),
            trailing: currentFilterType == 'unread'
                ? Icon(Icons.check, color: context.primaryColor)
                : null,
            onTap: () {
              onFilterChanged('unread');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.smart_toy,
              color: currentFilterType == 'chatbot'
                  ? context.primaryColor
                  : Colors.grey,
            ),
            title: const Text('Hỗ trợ Drivio (Chatbot)'),
            trailing: currentFilterType == 'chatbot'
                ? Icon(Icons.check, color: context.primaryColor)
                : null,
            onTap: () {
              onFilterChanged('chatbot');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
