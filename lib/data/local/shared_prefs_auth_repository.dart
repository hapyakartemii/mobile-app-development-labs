import 'package:flutter_lab1/data/local/json_list_store.dart';
import 'package:flutter_lab1/data/local/user_record.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [IAuthRepository] backed by SharedPreferences: users as a JSON list,
/// the session as the signed-in user's id.
class SharedPrefsAuthRepository implements IAuthRepository {
  SharedPrefsAuthRepository(this._prefs, {Duration latency = Duration.zero})
    : _store = JsonListStore(_prefs, latency: latency);

  static const usersKey = 'auth.users';
  static const sessionKey = 'auth.session';
  static const _invalidCredentials = 'Невірний email або пароль';

  final SharedPreferences _prefs;
  final JsonListStore _store;

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
    await _prefs.setString(sessionKey, record.user.id);
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

    await _prefs.setString(sessionKey, match.user.id);
    return match.user;
  }

  @override
  Future<AppUser?> currentUser() async {
    final id = _prefs.getString(sessionKey);
    if (id == null) return null;
    final records = await _readRecords();
    return records.where((record) => record.user.id == id).firstOrNull?.user;
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(sessionKey);
  }

  Future<List<UserRecord>> _readRecords() async {
    final items = await _store.read(usersKey);
    return [for (final json in items) UserRecord.fromJson(json)];
  }

  static String _normalize(String email) => email.trim().toLowerCase();
}
