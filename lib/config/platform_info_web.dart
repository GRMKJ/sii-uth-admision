// Web implementation: avoid importing dart:io
class PlatformInfo {
  static String get version => 'web';
  static bool get isAndroid => false;
  static bool get isIOS => false;
}
