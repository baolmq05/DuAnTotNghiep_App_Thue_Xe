import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivityHelper {
  /// Checks whether the device has a working internet connection.
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) {
      try {
        // On web, perform a lightweight HTTP HEAD request
        final response = await http.head(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 4));
        return response.statusCode >= 200 && response.statusCode < 400;
      } catch (_) {
        return false;
      }
    } else {
      try {
        // On native platforms, look up google.com DNS.
        // This is more reliable than network state checking as it verifies actual data path.
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      } catch (_) {
        return false;
      }
    }
  }
}
