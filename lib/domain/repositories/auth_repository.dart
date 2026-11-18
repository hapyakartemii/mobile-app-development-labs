import 'package:flutter_lab1/domain/entities/app_user.dart';

/// Authentication contract.
///
/// Screens depend only on this abstraction. The storage behind it
/// (SharedPreferences now, a REST API later) can be swapped in `main.dart`
/// without touching the UI.
abstract interface class IAuthRepository {
  /// Saves a new user and starts a session.
  /// Throws [AuthException] if the data is invalid or the email is taken.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  /// Checks the credentials against stored users and starts a session.
  /// Throws [AuthException] if they don't match.
  Future<AppUser> login({required String email, required String password});

  /// User of the saved session, or `null` if nobody is signed in.
  Future<AppUser?> currentUser();

  Future<void> logout();
}

/// Expected auth failure with a message safe to show to the user.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
