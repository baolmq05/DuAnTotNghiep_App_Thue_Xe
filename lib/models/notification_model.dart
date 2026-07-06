class Notification {
  final int id;
  final String message;
  final bool isRead;
  final String userId;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.userId,
    required this.createdAt,
  });

  Notification copyWith({
    int? id,
    String? message,
    bool? isRead,
    String? userId,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // hàm tính ngày
  String get timeAgo {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );

    if (notificationDate == today) {
      return 'Hôm nay';
    } else if (notificationDate == yesterday) {
      return 'Hôm qua';
    } else {
      final difference = today.difference(notificationDate).inDays;
      if (difference < 7) {
        return '$difference ngày trước';
      } else {
        return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
      }
    }
  }

  // hàm tính giờ
  String get displayTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Notification(
      id: json['id'] as int,
      message: json['message'] as String,
      isRead:
          json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['is_read'] == '1',
      userId: (json['user_id']).toString(),
      createdAt: parseDate(json['created_at'] ?? json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
