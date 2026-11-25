import 'package:flutter_lab1/data/local/user_record.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:shelf/shelf.dart';

import 'http_helpers.dart';
import 'json_db.dart';
import 'jwt.dart';

/// `/auth/register`, `/auth/login` and `/me`.
class AuthHandlers {
  AuthHandlers(this._db, this._jwt);

  final JsonDb _db;
  final Jwt _jwt;

  Future<Response> register(Request request) async {
    final body = await readJson(request);
    final name = textField(body, 'name');
    final email = textField(body, 'email').toLowerCase();
    final password = body['password'] is String
        ? body['password'] as String
        : '';

    // Same rules as the app's forms, so the server never trusts the client.
    final error = Validators.firstError([
      Validators.name(name),
      Validators.email(email),
      Validators.password(password),
    ]);
    if (error != null) return errorResponse(400, error);
    if (_db.userByEmail(email) != null) {
      return errorResponse(409, 'Користувач з таким email уже існує');
    }

    final user = {
      'id': DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
      'passwordHash': UserRecord.hash(password, email),
    };
    await _db.addUser(user);
    return jsonResponse(_session(user), status: 201);
  }

  Future<Response> login(Request request) async {
    final body = await readJson(request);
    final email = textField(body, 'email').toLowerCase();
    final password = body['password'] is String
        ? body['password'] as String
        : '';

    final user = _db.userByEmail(email);
    if (user == null ||
        user['passwordHash'] != UserRecord.hash(password, email)) {
      return errorResponse(401, 'Невірний email або пароль');
    }
    return jsonResponse(_session(user));
  }

  Response me(Request request) {
    final user = _db.userById(userIdOf(request));
    if (user == null) return errorResponse(404, 'Користувача не знайдено');
    return jsonResponse(publicUser(user));
  }

  Map<String, Object> _session(Map<String, dynamic> user) => {
    'token': _jwt.issue(user['id'] as String),
    'user': publicUser(user),
  };

  /// User without the password hash: the only shape the API sends out.
  static Map<String, Object> publicUser(Map<String, dynamic> user) => {
    'id': user['id'] as String,
    'name': user['name'] as String,
    'email': user['email'] as String,
    'createdAt': user['createdAt'] as String,
  };
}
