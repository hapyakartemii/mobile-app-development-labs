/// Tells whether the device can reach the internet.
abstract interface class IConnectivityService {
  /// One-off check, e.g. before sending a login request.
  Future<bool> isOnline();

  /// Emits `true` / `false` every time the connection state changes.
  Stream<bool> get onlineChanges;
}
