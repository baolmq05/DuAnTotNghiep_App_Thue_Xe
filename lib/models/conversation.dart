class OtherUser {
  final int id;
  final String name;
  final String? avatar;

  OtherUser({required this.id, required this.name, this.avatar});

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

class CarChat {
  final int id;
  final String name;
  final String? image;

  CarChat({required this.id, required this.name, this.image});

  factory CarChat.fromJson(Map<String, dynamic> json) {
    return CarChat(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

class LastMessage {
  final String text;
  final String type;
  final int sender_id;
  final String created_at;

  LastMessage({
    required this.text,
    required this.type,
    required this.sender_id,
    required this.created_at,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      text: json['text']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      sender_id: json['sender_id'] is int ? json['sender_id'] : int.tryParse(json['sender_id']?.toString() ?? '') ?? 0,
      created_at: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'sender_id': sender_id,
      'created_at': created_at,
    };
  }
}

class Conversation {
  final String id; // Sử dụng String để tương thích hoàn toàn với UI cũ
  final int status;
  final int? tripId;
  final String createdAt;
  final String updatedAt;
  final OtherUser otherUser;
  final CarChat? car;
  final LastMessage? lastMessageObj;
  final int unreadCount;

  // Constructor dùng cho việc map API hoặc nội bộ
  Conversation.raw({
    required this.id,
    required this.status,
    this.tripId,
    required this.createdAt,
    required this.updatedAt,
    required this.otherUser,
    this.car,
    this.lastMessageObj,
    this.unreadCount = 0,
  });

  // Constructor mặc định khớp với thiết kế UI giả lập cũ để tránh lỗi biên dịch
  factory Conversation({
    required String id,
    required String name,
    required String avatarUrl,
    required String lastMessage,
    required String time,
    bool isChatbot = false,
    String? attachmentImageUrl,
    int unreadCount = 0,
    bool isOnline = false,
  }) {
    return Conversation.raw(
      id: id,
      status: isOnline ? 1 : 0,
      createdAt: time,
      updatedAt: time,
      otherUser: OtherUser(id: 0, name: name, avatar: avatarUrl),
      car: attachmentImageUrl != null ? CarChat(id: 0, name: '', image: attachmentImageUrl) : null,
      lastMessageObj: LastMessage(
        text: lastMessage,
        type: 'text',
        sender_id: 0,
        created_at: time,
      ),
      unreadCount: unreadCount,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation.raw(
      id: json['id']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      tripId: json['trip_id'] is int ? json['trip_id'] : int.tryParse(json['trip_id']?.toString() ?? ''),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      otherUser: json['other_user'] != null
          ? OtherUser.fromJson(json['other_user'])
          : OtherUser(id: 0, name: 'Người dùng'),
      car: json['car'] != null ? CarChat.fromJson(json['car']) : null,
      lastMessageObj: json['last_message'] != null ? LastMessage.fromJson(json['last_message']) : null,
      unreadCount: json['unread_count'] is int ? json['unread_count'] : int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'trip_id': tripId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'other_user': otherUser.toJson(),
      'car': car?.toJson(),
      'last_message': lastMessageObj?.toJson(),
      'unread_count': unreadCount,
    };
  }

  // --- Các Getters duy trì tương thích ngược với Giao diện (UI) cũ ---
  String get name => otherUser.name;
  String get avatarUrl => otherUser.avatar ?? '';
  String get lastMessage => lastMessageObj?.text ?? '';
  String get time {
    if (lastMessageObj != null) {
      final String cat = lastMessageObj!.created_at;
      if (cat.length >= 16) {
        return cat.substring(11, 16); // Lấy dạng HH:mm
      }
      return cat;
    }
    if (updatedAt.length >= 16) {
      return updatedAt.substring(11, 16);
    }
    return updatedAt;
  }
  bool get isChatbot => name.toLowerCase().contains('chatbot') || name.toLowerCase().contains('hỗ trợ drivio');
  String? get attachmentImageUrl => car?.image;
  bool get isOnline => status == 1;
}
