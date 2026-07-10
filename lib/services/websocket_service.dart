import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class WebSocketService extends BaseService {
  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? channel;
  String? socketId;

  // Track subscribed channels to prevent duplicates
  final Set<String> _subscribedChannels = {};

  // Broadcast stream to send events to all listeners
  final _messageStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  void connect() {
    // If already connected, do not reconnect
    if (channel != null) return;

    socketId = null;
    final host = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : '127.0.0.1';
    final url =
        'ws://$host:8080/app/bp54cuveeawxyvoq2yk9?protocol=7&client=js&version=7.0.6';

    try {
      debugPrint('Connecting to WebSocket: $url');
      channel = WebSocketChannel.connect(Uri.parse(url));

      channel!.stream.listen(
        (message) {
          debugPrint('WebSocket received: $message');

          final data = jsonDecode(message.toString());

          if (data['event'] == 'pusher:connection_established') {
            final eventData = jsonDecode(data['data']);
            socketId = eventData['socket_id'];
            debugPrint("SocketId is $socketId");
          }

          // Broadcast all received packets
          _messageStreamController.add(data);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
        },
        onDone: () {
          debugPrint('WebSocket closed.');
          _cleanupConnection();
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
    }
  }

  void _cleanupConnection() {
    channel = null;
    socketId = null;
    _subscribedChannels.clear();
  }

  /// Disconnect
  void disconnect() {
    channel?.sink.close();
    _cleanupConnection();
  }

  Future<void> subscribe(String channelName) async {
    // If already subscribed, skip
    if (_subscribedChannels.contains(channelName)) {
      debugPrint('Already subscribed to channel: $channelName');
      return;
    }

    int attempts = 0;
    while (socketId == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    if (socketId == null) {
      debugPrint('Cannot subscribe to $channelName: socketId is null');
      return;
    }
    try {
      final authResponse = await store(
        'api/broadcasting/auth',
        body: {'socket_id': socketId, 'channel_name': channelName},
        requiresAuth: true,
      );

      if (authResponse != null && authResponse['auth'] != null) {
        channel?.sink.add(
          jsonEncode({
            'event': 'pusher:subscribe',
            'data': {'channel': channelName, 'auth': authResponse['auth']},
          }),
        );
        _subscribedChannels.add(channelName);
        debugPrint('Sent subscription request for $channelName');
      }
    } catch (e) {
      debugPrint('Subscription authentication failed: $e');
    }
  }

  void unsubscribe(String channelName) {
    if (channel != null && _subscribedChannels.contains(channelName)) {
      channel?.sink.add(
        jsonEncode({
          'event': 'pusher:unsubscribe',
          'data': {'channel': channelName},
        }),
      );
      _subscribedChannels.remove(channelName);
      debugPrint('Unsubscribed from $channelName');
    }
  }
}
