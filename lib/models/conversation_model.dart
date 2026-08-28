import 'dart:convert';

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
  String get name {
    if (isChatbot) return 'Chatbot Drivio';
    return otherUser.name;
  }
  String get avatarUrl => otherUser.avatar ?? '';
  String get lastMessage => lastMessageObj?.text ?? '';
  String get displayLastMessage => formatMessagePreview(lastMessage);

  static String formatMessagePreview(String rawMessage) {
    if (rawMessage.trim().isEmpty) return '';
    final text = rawMessage.trim();

    // 1. Nếu chứa code block markdown (```json ... ``` hoặc ``` ... ```)
    if (text.contains('```')) {
      final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
      final match = codeBlockRegex.firstMatch(text);
      if (match != null) {
        final inside = match.group(1)?.trim() ?? '';
        final jsonResult = _extractJsonSummary(inside);
        if (jsonResult != null) return jsonResult;
      }
    }

    // 2. Thử parse JSON trực tiếp hoặc từ khối JSON trong văn bản
    final jsonResult = _extractJsonSummary(text);
    if (jsonResult != null) return jsonResult;

    // 3. Link hình ảnh / tập tin
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
      '.svg',
    ];
    if (text.startsWith('http://') || text.startsWith('https://')) {
      final lower = text.toLowerCase();
      if (imageExtensions.any((ext) => lower.contains(ext))) {
        return 'Đã gửi một hình ảnh';
      }
      return 'Đã gửi một liên kết';
    }

    // 4. Văn bản Markdown thông thường: làm sạch ký tự định dạng
    return _cleanMarkdownText(text);
  }

  static String? _extractJsonSummary(String input) {
    final trimmed = input.trim();

    // 2.1 Thử tìm và parse JSON Object { ... }
    final firstBrace = trimmed.indexOf('{');
    final lastBrace = trimmed.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      try {
        final candidate = trimmed.substring(firstBrace, lastBrace + 1);
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic>) {
          // Nếu có message riêng (VD: "Drivio hiện có 3 xe phù hợp...", "Không tìm thấy xe...")
          final msg = decoded['message']?.toString().trim();
          if (msg != null && msg.isNotEmpty) {
            return _cleanMarkdownText(msg);
          }

          // Nếu có mảng cars
          if (decoded['cars'] is List) {
            final cars = decoded['cars'] as List;
            if (cars.isEmpty) {
              return 'Không tìm thấy xe phù hợp';
            }
            final names = cars
                .whereType<Map>()
                .map((c) => c['name']?.toString().trim())
                .where((n) => n != null && n.isNotEmpty)
                .toList();
            if (names.isNotEmpty) {
              if (names.length == 1) {
                return 'Gợi ý xe: ${names.first}';
              }
              return 'Đã gợi ý ${cars.length} xe: ${names.take(2).join(', ')}${names.length > 2 ? '...' : ''}';
            }
            return 'Đã gợi ý ${cars.length} xe cho bạn';
          }

          // Nếu là JSON 1 xe đơn lẻ
          if (decoded.containsKey('name')) {
            return 'Gợi ý xe: ${decoded['name']}';
          }

          if (decoded.containsKey('text')) {
            return _cleanMarkdownText(decoded['text'].toString());
          }
        }
      } catch (_) {}
    }

    // 2.2 Thử tìm và parse JSON Array [ ... ]
    final firstBracket = trimmed.indexOf('[');
    final lastBracket = trimmed.lastIndexOf(']');
    if (firstBracket != -1 && lastBracket > firstBracket) {
      try {
        final candidate = trimmed.substring(firstBracket, lastBracket + 1);
        final decoded = jsonDecode(candidate);
        if (decoded is List) {
          if (decoded.isEmpty) {
            return 'Không tìm thấy xe phù hợp';
          }
          final names = decoded
              .whereType<Map>()
              .map((c) => c['name']?.toString().trim())
              .where((n) => n != null && n.isNotEmpty)
              .toList();
          if (names.isNotEmpty) {
            if (names.length == 1) {
              return 'Gợi ý xe: ${names.first}';
            }
            return 'Đã gợi ý ${decoded.length} xe: ${names.take(2).join(', ')}${names.length > 2 ? '...' : ''}';
          }
          return 'Đã gợi ý ${decoded.length} xe cho bạn';
        }
      } catch (_) {}
    }

    return null;
  }

  static String _cleanMarkdownText(String text) {
    var cleaned = text
        .replaceAll(RegExp(r'\*\*|__'), '') // Bỏ bold **text**
        .replaceAll(RegExp(r'\*|_'), '') // Bỏ italic *text*
        .replaceAll(RegExp(r'~~.*?~~'), '') // Bỏ strikethrough
        .replaceAll(RegExp(r'#+\s*'), '') // Bỏ headers #
        .replaceAll(RegExp(r'`+'), '') // Bỏ inline code `
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // Bỏ link [text](url) -> text
        .replaceAll(RegExp(r'[\r\n]+'), ' ') // Bỏ xuống dòng, thay bằng dấu cách
        .replaceAll(RegExp(r'\s+'), ' ') // Gộp khoảng trắng thừa
        .trim();
    return cleaned;
  }
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
  bool get isChatbot => id.startsWith('chatbot') ||
                        otherUser.name.toLowerCase().contains('chatbot') || 
                        otherUser.name.toLowerCase().contains('hỗ trợ drivio') || 
                        otherUser.name.toLowerCase().contains('trợ lý ai');
  String? get attachmentImageUrl => car?.image;
  bool get isOnline => status == 1;
}
