// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'web_notifications_types.dart';

Future<bool> showBrowserNotification({
  required String title,
  required String body,
  String? payload,
  NotificationTapCallback? onTap,
}) async {
  if (!html.Notification.supported) {
    return false;
  }

  if (html.Notification.permission == 'denied') {
    return false;
  }

  if (html.Notification.permission != 'granted') {
    final result = await html.Notification.requestPermission();
    if (result != 'granted') {
      return false;
    }
  }

  final notification = html.Notification(
    title,
    body: body.isEmpty ? null : body,
    tag: 'siiadmision-foreground',
    icon: _resolveIcon(),
  );

  notification.onClick.listen((event) {
    event.preventDefault();
    notification.close();
    onTap?.call();
  });

  return true;
}

String? _resolveIcon() {
  try {
    final origin = html.window.location.origin;
    if (origin.isEmpty) {
      return null;
    }
    return '$origin/icons/Icon-192.png';
  } catch (_) {
    return null;
  }
}
