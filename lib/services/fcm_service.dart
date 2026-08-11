import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

/// Top-level background message handler cho FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('XỬ LÝ THÔNG BÁO BACKGROUND: ${message.messageId}');
  debugPrint('Nội dung: ${message.notification?.title} - ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

class FcmService extends BaseService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel', // id
    'Thông báo Drivio', // name
    description: 'Kênh thông báo đẩy hệ thống và tin nhắn cho ứng dụng Drivio',
    importance: Importance.high,
    playSound: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Callback chuyển hướng khi người dùng nhấn vào thông báo
  Function(Map<String, dynamic> data)? onNotificationClick;

  /// Khởi tạo Firebase Cloud Messaging và Local Notifications
  Future<void> initialize() async {
    try {
      // 1. Xin quyền thông báo
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Trạng thái quyền FCM: ${settings.authorizationStatus}');

      // 2. Khởi tạo Flutter Local Notifications (hiển thị banner khi app foreground)
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Đã nhấn vào thông báo local: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              _handleNotificationPayload(data);
            } catch (e) {
              debugPrint('Lỗi parse payload notification: $e');
            }
          }
        },
      );

      // Tạo Android Channel nếu chạy trên Android
      final androidPlatform = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(_androidChannel);
      }

      // 3. Cấu hình foreground presentation trên iOS
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Lắng nghe background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. Lắng nghe foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('NHẬN THÔNG BÁO FOREGROUND: ${message.notification?.title}');
        debugPrint('Nội dung: ${message.notification?.body}');
        debugPrint('Data payload: ${message.data}');

        final combinedData = _extractMessageData(message);
        final title = combinedData['title'] ?? 'Thông báo mới';
        final body = combinedData['body'] ?? combinedData['message'] ?? '';

        if (title.isNotEmpty || body.isNotEmpty) {
          showLocalNotification(
            title: title,
            body: body,
            payload: jsonEncode(combinedData),
          );
        }
      });

      // 6. Xử lý khi bấm vào thông báo đẩy từ thanh trạng thái (Background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final data = _extractMessageData(message);
        debugPrint('Mở app từ thông báo đẩy (Background): $data');
        _handleNotificationPayload(data);
      });

      // 7. Xử lý khi app bị đóng hoàn toàn và được mở từ thông báo (Terminated)
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        final data = _extractMessageData(initialMessage);
        debugPrint('Mở app từ thông báo đẩy (Terminated): $data');
        _handleNotificationPayload(data);
      }

      // 8. Lấy và theo dõi FCM Token
      await _fetchFcmToken();
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token làm mới: $newToken');
        sendFcmTokenToServer(newToken);
      });
    } catch (e) {
      debugPrint('LỖI KHỞI TẠO FCM SERVICE: $e');
    }
  }

  /// Lấy FCM Token thiết bị
  Future<String?> _fetchFcmToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('====================================');
      debugPrint('FCM TOKEN THIẾT BỊ: $_fcmToken');
      debugPrint('====================================');
      if (_fcmToken != null) {
        await sendFcmTokenToServer(_fcmToken!);
      }
      return _fcmToken;
    } catch (e) {
      debugPrint('Lỗi lấy FCM Token: $e');
      return null;
    }
  }

  /// Hiển thị thông báo đẩy cục bộ (pop-up banner)
  Future<void> showLocalNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Thông báo Drivio',
      channelDescription: 'Kênh thông báo đẩy hệ thống và tin nhắn cho ứng dụng Drivio',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Xử lý điều hướng khi người dùng nhấn vào thông báo
  void _handleNotificationPayload(Map<String, dynamic> data) {
    if (onNotificationClick != null) {
      onNotificationClick!(data);
    }
  }

  /// Gộp dữ liệu data payload và notification payload thành Map<String, dynamic>
  Map<String, dynamic> _extractMessageData(RemoteMessage message) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    if (message.notification != null) {
      if (message.notification!.title != null) {
        data.putIfAbsent('title', () => message.notification!.title);
      }
      if (message.notification!.body != null) {
        data.putIfAbsent('body', () => message.notification!.body);
      }
    }
    return data;
  }

  /// Gửi FCM Token lên backend nếu người dùng đã đăng nhập
  Future<void> sendFcmTokenToServer(String token) async {
    try {
      final savedToken = await getSavedToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        await store(
          'api/auth/fcm-token',
          body: {'fcm_token': token},
          requiresAuth: true,
        );
        debugPrint('Đã gửi FCM Token lên server thành công.');
      }
    } catch (e) {
      debugPrint('Lỗi gửi FCM Token lên server (bỏ qua nếu server chưa tạo endpoint): $e');
    }
  }
}
