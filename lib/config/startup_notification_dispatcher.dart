import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';

class StartupNotificationDispatcher {
  StartupNotificationDispatcher._();

  static String? _cachedFcmToken;
  static bool _notificationSent = false;
  static bool _sending = false;

  static Future<void> registerFcmToken(String? token) async {
    if (token == null || token.isEmpty) {
      return;
    }
    _cachedFcmToken = token;
    await _trySend();
  }

  static Future<void> notifyAfterAuthentication() async {
    await _trySend();
  }

  static Future<void> _trySend() async {
    if (_notificationSent || _sending) {
      return;
    }

    final fcmToken = _cachedFcmToken;
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    const storage = FlutterSecureStorage();
    final authToken = await storage.read(key: 'auth_token');
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    _sending = true;
    try {
      final response = await ApiClient.postJson(
        '/notifications/test',
        token: authToken,
        body: {'token': fcmToken},
      );
      _notificationSent = true;
      debugPrint(response.toString());
      
    } catch (e, st) {
      debugPrint('No se pudo solicitar la notificación de prueba: $e');
      debugPrint('$st');
    } finally {
      _sending = false;
    }
  }
}
