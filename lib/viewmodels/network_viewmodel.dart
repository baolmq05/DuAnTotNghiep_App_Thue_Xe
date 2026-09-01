import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class NetworkViewModel extends ChangeNotifier with WidgetsBindingObserver {
  bool _isOnline = true;
  bool _isChecking = false;
  Timer? _periodicTimer;

  bool get isOnline => _isOnline;
  bool get isChecking => _isChecking;

  NetworkViewModel() {
    WidgetsBinding.instance.addObserver(this);
    // Initial check
    checkConnection();
    // Start periodic check every 5 seconds
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _silentCheck();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkConnection();
    }
  }

  /// Explicit check (triggers loading indicator for user on manual retry)
  Future<bool> checkConnection() async {
    _isChecking = true;
    notifyListeners();

    final online = await _pingInternet();
    _isOnline = online;
    _isChecking = false;
    notifyListeners();
    return online;
  }

  /// Silent background check (does not toggle isChecking to avoid UI flicker)
  Future<void> _silentCheck() async {
    final online = await _pingInternet();
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  /// Tests true internet reachability via DNS lookup with timeout
  Future<bool> _pingInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      // Fallback check to 1.1.1.1 or cloudflare in case of DNS hiccup
      try {
        final fallback = await InternetAddress.lookup('cloudflare.com')
            .timeout(const Duration(seconds: 3));
        if (fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    super.dispose();
  }
}
