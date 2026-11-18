import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';

/// How a user is stored on the device: profile plus password hash.
/// The plain password is never saved.
class UserRecord {
  const UserRecord({required this.user, required this.passwordHash});

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      user: AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      ),
      passwordHash: json['passwordHash'] as String,
    );
  }

  final AppUser user;
  final String passwordHash;

  Map<String, Object> toJson() => {
    'id': user.id,
    'name': user.name,
    'email': user.email,
    'createdAt': user.createdAt.toIso8601String(),
    'passwordHash': passwordHash,
  };

  /// SHA-256 of the password salted with the email.
  static String hash(String password, String email) =>
      sha256.convert(utf8.encode('$email:$password')).toString();
}
