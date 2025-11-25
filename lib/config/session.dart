import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/local_user_store.dart';

class Session {
  static final Session _instance = Session._internal();
  factory Session() => _instance;
  Session._internal();

  String? role;
  LocalIdentity? _identity;

  bool get isLoggedIn => role != null;
  bool get isAspirante => role == 'aspirante';
  bool get isAdmin => role == 'admin';
  bool get isAlumno => role == 'alumno';

  LocalIdentity? get identity => _identity;
  String? get displayName => (_identity?.name ?? '').isNotEmpty ? _identity!.name : null;
  String? get identifier => (_identity?.identifier ?? '').isNotEmpty ? _identity!.identifier : null;
  String? get identifierLabel => (_identity?.identifierLabel ?? '').isNotEmpty ? _identity!.identifierLabel : null;

  void loginAs(String r) => role = _normalizeRole(r) ?? r;
  void logout() {
    role = null;
    _identity = null;
  }

  Future<void> load() async {
    final storage = FlutterSecureStorage();
    final storedRole = await storage.read(key: "role");
    role = _normalizeRole(storedRole);

    _identity = await LocalUserStore.instance.read();
    if (_identity != null && role == null) {
      role = _normalizeRole(_identity!.role);
    }
  }

  Future<void> saveIdentity(LocalIdentity identity) async {
    _identity = identity;
    await LocalUserStore.instance.save(identity);
  }

  Future<void> clearPersistentIdentity() async {
    _identity = null;
    await LocalUserStore.instance.clear();
  }

  Future<void> clearPersistentRole() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: "role");
  }

  String? _normalizeRole(String? role) {
    if (role == null) return null;
    switch (role) {
      case "administrativo":
      case "admin":
        return "admin";
      case "alumno":
        return "alumno";
      case "aspirante":
        return "aspirante";
      default:
        return null;
    }
  }
}
