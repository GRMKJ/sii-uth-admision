import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static Future<void> saveStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progress_step', step);
  }

  static Future<int> getStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('progress_step') ?? 0;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('progress_step');
  }
}
