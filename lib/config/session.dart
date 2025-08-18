import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  static final Session _instance = Session._internal();
  factory Session() => _instance;
  Session._internal();

  String? role; // 'admin' o 'alumno'
  bool get isLoggedIn => role != null;
  bool get isAspirante => role == 'aspirante';
  bool get isAdmin => role == 'admin';
  bool get isAlumno => role == 'alumno';

  void loginAs(String r) => role = r;
  void logout() => role = null;

  Future<void> load() async {
    final storage = FlutterSecureStorage();
    final role = await storage.read(key: "role");
    if (role == "administrativo") {
      this.role = "admin";
    } else if (role == "alumno") {
      this.role = "alumno";
    } else if (role == "aspirante") {
      this.role = "aspirante";
    } else {
      this.role = null;
    }
  }
}