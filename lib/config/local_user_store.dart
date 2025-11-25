import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lightweight cache to keep the last authenticated user identity available offline.
class LocalUserStore {
  LocalUserStore._();

  static final LocalUserStore instance = LocalUserStore._();
  static const _storageKey = 'local_user_identity';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> save(LocalIdentity identity) async {
    await _storage.write(key: _storageKey, value: jsonEncode(identity.toJson()));
  }

  Future<LocalIdentity?> read() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return LocalIdentity.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _storageKey);
  }
}

class LocalIdentity {
  final String role;
  final String name;
  final String identifier;
  final String identifierLabel;
  final DateTime savedAt;

  LocalIdentity({
    required this.role,
    required this.name,
    required this.identifier,
    required this.identifierLabel,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'name': name,
        'identifier': identifier,
        'identifierLabel': identifierLabel,
        'savedAt': savedAt.toIso8601String(),
      };

  factory LocalIdentity.fromJson(Map<String, dynamic> json) {
    return LocalIdentity(
      role: json['role'] as String? ?? '',
      name: json['name'] as String? ?? '',
      identifier: json['identifier'] as String? ?? '',
      identifierLabel: json['identifierLabel'] as String? ?? '',
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  LocalIdentity copyWith({
    String? role,
    String? name,
    String? identifier,
    String? identifierLabel,
    DateTime? savedAt,
  }) {
    return LocalIdentity(
      role: role ?? this.role,
      name: name ?? this.name,
      identifier: identifier ?? this.identifier,
      identifierLabel: identifierLabel ?? this.identifierLabel,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
