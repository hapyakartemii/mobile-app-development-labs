import 'dart:math';

import 'package:flutter_lab1/data/local/json_list_store.dart';
import 'package:flutter_lab1/data/local/user_record.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/entities/session.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/session_storage.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [IAuthRepository] with users (and password hashes) in SharedPreferences
/// and the session token in [ISessionStorage] (encrypted storage).
class SharedPrefsAuthRepository implements IAuthRepository {
  SharedPrefsAuthRepository(
    SharedPreferences prefs,
    this._sessions, {
    Duration latency = Duration.zero,
  }) : _store = JsonListStore(prefs, latency: latency);

  static const usersKey = 'auth.users';
  static const _invalidCredentials = 'Невірний email або пароль';

  final ISessionStorage _sessions;
  final JsonListStore _store;
  final Random _random = Random.secure();

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final error = Validators.firstError([
      Validators.name(name),
      Validators.email(email),
      Validators.password(password),
    ]);
    if (error != null) throw AuthException(error);

    final normalizedEmail = _normalize(email);
    final records = await _readRecords();
    if (records.any((record) => record.user.email == normalizedEmail)) {
      throw const AuthException('Користувач з таким email уже існує');
    }

    final record = UserRecord(
      user: AppUser(
        id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
        name: name.trim(),
        email: normalizedEmail,
        createdAt: DateTime.now(),
      ),
      passwordHash: UserRecord.hash(password, normalizedEmail),
    );
    await _store.write(usersKey, [
      for (final existing in records) existing.toJson(),
      record.toJson(),
    ]);
    await _startSession(record.user);
    return record.user;
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalize(email);
    final records = await _readRecords();
    final hash = UserRecord.hash(password, normalizedEmail);
    final match = records
        .where((record) => record.user.email == normalizedEmail)
        .firstOrNull;
    if (match == null || match.passwordHash != hash) {
      throw const AuthException(_invalidCredentials);
    }

    await _startSession(match.user);
    return match.user;
  }

  /// Auto-login: restores the user from the saved session, without
  /// network, so it also works offline.
  @override
  Future<AppUser?> currentUser() async {
    final session = await _sessions.read();
    if (session == null) return null;
    final records = await _readRecords();
    final user = records
        .where((record) => record.user.id == session.userId)
        .firstOrNull
        ?.user;
    if (user == null) await _sessions.clear();
    return user;
  }

  @override
  Future<void> logout() => _sessions.clear();

  Future<void> _startSession(AppUser user) => _sessions.save(
    Session(token: _newToken(), userId: user.id, createdAt: DateTime.now()),
  );

  /// 32 random bytes as hex, from a cryptographically secure generator.
  String _newToken() => [
    for (var i = 0; i < 32; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();

  Future<List<UserRecord>> _readRecords() async {
    final items = await _store.read(usersKey);
    return [for (final json in items) UserRecord.fromJson(json)];
  }

  static String _normalize(String email) => email.trim().toLowerCase();
}
