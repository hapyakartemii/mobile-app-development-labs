import 'package:flutter_lab1/domain/entities/session.dart';

/// Where the session is kept between launches.
/// Implemented with encrypted storage (Keychain / Android Keystore).
abstract interface class ISessionStorage {
  /// Saved session, or `null` if the user isn't signed in.
  Future<Session?> read();

  Future<void> save(Session session);

  Future<void> clear();
}
