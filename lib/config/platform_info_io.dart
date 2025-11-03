import 'dart:io';

class PlatformInfo {
  /// Full platform version string provided by dart:io
  static String get version => Platform.version;

  /// Platform checks
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
}
