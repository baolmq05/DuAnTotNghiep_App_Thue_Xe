import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/notification_model.dart'
    as notification_model;
import 'package:duantotnghiep_app_thue_xe/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  final NotificationService _notificationService;

  final List<notification_model.Notification> _allNotifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<notification_model.Notification> get allNotifications =>
      _allNotifications;
  int get unreadCount =>
      _allNotifications.where((item) => !item.isRead).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final notifications = await _notificationService.fetchNotifications();
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
}
