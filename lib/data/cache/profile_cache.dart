import 'dart:convert';

import 'package:flutter_lab1/data/remote/dto/user_dto.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Last profile received from the server, so auto-login and the profile
/// screen work without the internet.
class ProfileCache {
  const ProfileCache(this._prefs);

  static const _key = 'cache.profile';

  final SharedPreferences _prefs;

  Future<void> save(AppUser user) =>
      _prefs.setString(_key, jsonEncode(UserDto.fromEntity(user).toJson()));

  AppUser? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    return UserDto.fromJson(jsonDecode(raw) as Map<String, dynamic>).toEntity();
  }

  Future<void> clear() => _prefs.remove(_key);
}
