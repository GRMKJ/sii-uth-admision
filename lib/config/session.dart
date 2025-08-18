

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
}