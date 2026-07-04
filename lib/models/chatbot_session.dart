class ChatbotSession {
  final int id;
  final int userId;
  final String title;
  final String createdAt;
  final String updatedAt;
  final List<dynamic> messages;

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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Trợ lý AI',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      messages: json['messages'] is List ? json['messages'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'messages': messages,
    };
  }
}
