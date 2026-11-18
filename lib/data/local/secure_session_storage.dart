import 'dart:convert';

import 'package:flutter_lab1/domain/entities/session.dart';
import 'package:flutter_lab1/domain/repositories/session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [ISessionStorage] in encrypted storage: iOS Keychain, Android Keystore.
/// Unlike SharedPreferences, other apps and backups can't read the token.
class SecureSessionStorage implements ISessionStorage {
  SecureSessionStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth.session';

  final FlutterSecureStorage _storage;

  @override
  Future<Session?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Session(
      token: json['token'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  Future<void> save(Session session) => _storage.write(
    key: _key,
    value: jsonEncode({
      'token': session.token,
      'userId': session.userId,
      'createdAt': session.createdAt.toIso8601String(),
    }),
  );

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
