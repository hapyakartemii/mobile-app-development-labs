import 'package:flutter_lab1/data/cache/profile_cache.dart';
import 'package:flutter_lab1/data/remote/api_client.dart';
import 'package:flutter_lab1/data/remote/api_exception.dart';
import 'package:flutter_lab1/data/remote/dto/user_dto.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/entities/session.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/session_storage.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';

/// [IAuthRepository] over the REST API with JWT.
///
/// The server issues the token; it's kept in [ISessionStorage]
/// (Keychain / Keystore) and sent by [ApiClient] in every request.
/// The profile is cached, so auto-login works without the internet.
class RemoteAuthRepository implements IAuthRepository {
  RemoteAuthRepository({
    required this._api,
    required this._sessions,
    required this._profileCache,
  });

  final ApiClient _api;
  final ISessionStorage _sessions;
  final ProfileCache _profileCache;

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) {
    final error = Validators.firstError([
      Validators.name(name),
      Validators.email(email),
      Validators.password(password),
    ]);
    if (error != null) throw AuthException(error);
    return _authenticate('/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
  }

  @override
  Future<AppUser> login({required String email, required String password}) =>
      _authenticate('/auth/login', {
        'email': email.trim(),
        'password': password,
      });

  /// Auto-login: refreshes the profile from `/me`; if the server can't be
  /// reached, falls back to the cached profile. A rejected token ends
  /// the session.
  @override
  Future<AppUser?> currentUser() async {
    if (await _sessions.read() == null) return null;
    try {
      final json = ApiClient.objectOf(await _api.get('/me'));
      final user = UserDto.fromJson(json).toEntity();
      await _profileCache.save(user);
      return user;
    } on ApiException catch (error) {
      if (error.isUnauthorized || error.statusCode == 404) {
        await logout();
        return null;
      }
      return _profileCache.read();
    }
  }

  @override
  Future<void> logout() async {
    await _sessions.clear();
    await _profileCache.clear();
  }

  Future<AppUser> _authenticate(String path, Map<String, Object> body) async {
    try {
      final json = ApiClient.objectOf(await _api.post(path, body));
      final reply = AuthResponseDto.fromJson(json);
      await _sessions.save(
        Session(
          token: reply.token,
          userId: reply.user.id,
          createdAt: DateTime.now(),
        ),
      );
      final user = reply.user.toEntity();
      await _profileCache.save(user);
      return user;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }
}
