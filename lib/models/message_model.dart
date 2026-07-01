class Conversation {
  final String id;
  final String name;
  final String avatarUrl; 
  final String lastMessage;
  final String time;
  final bool isChatbot;
  final String? attachmentImageUrl; 
  final int unreadCount;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.isChatbot = false,
    this.attachmentImageUrl,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String? imageUrl; 

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
  });
}
