/// Saved login: lets the app sign the user in again on the next launch.
class Session {
  const Session({
    required this.token,
    required this.userId,
    required this.createdAt,
  });

  /// Random secret issued at login. A REST API would issue it instead.
  final String token;
  final String userId;
  final DateTime createdAt;
}
