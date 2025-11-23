import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Controls the global theme mode and persists it between launches.
class ThemeController extends ChangeNotifier {
  ThemeController._internal();

  static final ThemeController instance = ThemeController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _themeKey = 'preferred_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool get isDarkMode => _mode == ThemeMode.dark;

  Future<void> loadThemeMode() async {
    final stored = await _storage.read(key: _themeKey);
    switch (stored) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  Future<void> updateMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _storage.write(key: _themeKey, value: _serialize(mode));
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await updateMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final ThemeController themeController = ThemeController.instance;
