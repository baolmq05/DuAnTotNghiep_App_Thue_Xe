import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/notification_model.dart'
    as notification_model;
import 'package:duantotnghiep_app_thue_xe/services/notification_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/fcm_service.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  final NotificationService _notificationService;

  final List<notification_model.Notification> _allNotifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _pollingTimer;
  final Set<int> _knownNotificationIds = {};
  bool _isInitialFetchDone = false;

  List<notification_model.Notification> get allNotifications =>
      _allNotifications;
  int get unreadCount =>
      _allNotifications.where((item) => !item.isRead).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Bắt đầu lắng nghe và tự động quét thông báo mới mỗi 4 giây
  void startNotificationWatcher() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      checkNewNotificationsNow();
    });
    // Gọi ngay lần đầu
    checkNewNotificationsNow();
  }

  /// Dừng bộ quét thông báo
  void stopNotificationWatcher() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> checkNewNotificationsNow() async {
    try {
      final notifications = await _notificationService.fetchNotifications();
      if (notifications.isEmpty) return;

      if (!_isInitialFetchDone) {
        _knownNotificationIds.addAll(notifications.map((n) => n.id));
        _allNotifications.clear();
        _allNotifications.addAll(notifications);
        _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isInitialFetchDone = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Phát hiện các bản ghi thông báo MỚI chưa từng xuất hiện
      final newItems = notifications
          .where((n) => !_knownNotificationIds.contains(n.id))
          .toList();

      if (newItems.isNotEmpty) {
        for (final item in newItems) {
          _knownNotificationIds.add(item.id);

          // Trích xuất mã đơn hàng nếu có trong nội dung thông báo
          final match = RegExp(r'#(\d+)').firstMatch(item.message);
          final tripId = match?.group(1);

          // Nổ Push Notification xuống thanh trạng thái điện thoại (Chuông + Rung)
          FcmService().showLocalNotification(
            id: item.id,
            title: 'Thông báo Drivio 🔔',
            body: item.message,
            payload: jsonEncode({
              'type': 'notification',
              'id': item.id,
              'trip_id': tripId,
              'message': item.message,
            }),
          );
        }

        _allNotifications.clear();
        _allNotifications.addAll(notifications);
        _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi quét thông báo nền: $e');
    }
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final notifications = await _notificationService.fetchNotifications();
      _knownNotificationIds.addAll(notifications.map((n) => n.id));
      _isInitialFetchDone = true;
      _allNotifications.clear();
      _allNotifications.addAll(notifications);
      _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(notification_model.Notification notification) async {
    if (notification.isRead) return;

    final updatedNotification = notification.copyWith(isRead: true);
    _updateNotification(updatedNotification);
    notifyListeners();

    try {
      await _notificationService.markAsRead(notification);
    } catch (_) {
      _updateNotification(notification);
      notifyListeners();
    }
  }

  Future<void> deleteNotification(
    notification_model.Notification notification,
  ) async {
    try {
      await _notificationService.deleteNotification(notification);
      _allNotifications.removeWhere((item) => item.id == notification.id);
      _knownNotificationIds.remove(notification.id);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  void _updateNotification(
    notification_model.Notification updatedNotification,
  ) {
    for (int i = 0; i < _allNotifications.length; i++) {
      if (_allNotifications[i].id == updatedNotification.id) {
        _allNotifications[i] = updatedNotification;
        return;
      }
    }
  }

  /// Thêm thông báo mới nhận từ push notification hoặc WebSocket vào đầu danh sách
  void addNotificationFromPush({
    required int id,
    required String message,
    required String userId,
    DateTime? createdAt,
  }) {
    final newNotif = notification_model.Notification(
      id: id,
      message: message,
      isRead: false,
      userId: userId,
      createdAt: createdAt ?? DateTime.now(),
    );

    // Tránh trùng lặp ID
    _knownNotificationIds.add(id);
    _allNotifications.removeWhere((item) => item.id == id);
    _allNotifications.insert(0, newNotif);
    notifyListeners();
  }

  @override
  void dispose() {
    stopNotificationWatcher();
    super.dispose();
  }
}
