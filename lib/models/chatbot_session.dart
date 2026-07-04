class ChatbotMessage {
  final int id;
  final String conversation_id;
  final int user_id;
  final String role;
  final String content;
  final String created_at;
  final String updated_at;

  ChatbotMessage({
    required this.id,
    required this.conversation_id,
    required this.user_id,
    required this.role,
    required this.content,
    required this.created_at,
    required this.updated_at,
  });

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      conversation_id: json['conversation_id']?.toString() ?? '',
      user_id: json['user_id'] is int 
          ? json['user_id'] 
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      role: json['role']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      created_at: json['created_at']?.toString() ?? '',
      updated_at: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversation_id,
      'user_id': user_id,
      'role': role,
      'content': content,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}

class ChatbotSession {
  final int id;
  final int userId;
  final String title;
  final String createdAt;
  final String updatedAt;
  final List<ChatbotMessage> messages;

  ChatbotSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory ChatbotSession.fromJson(Map<String, dynamic> json) {
    return ChatbotSession(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Trợ lý AI',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      messages: json['messages'] is List
          ? (json['messages'] as List)
              .map((msg) => ChatbotMessage.fromJson(msg as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }
}
