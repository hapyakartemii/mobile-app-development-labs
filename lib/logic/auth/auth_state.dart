import 'package:equatable/equatable.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';

enum AuthStatus {
  /// Saved session not checked yet (splash screen).
  unknown,
  authenticated,
  unauthenticated,
}

/// Immutable snapshot of the session. A change means a new object, which
/// is how BlocBuilder knows it has to rebuild.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.error,
    this.startedOffline = false,
  });

  final AuthStatus status;
  final AppUser? user;

  /// Login, registration or logout request in progress.
  final bool isSubmitting;

  /// Message for the login / registration form, or `null`.
  final String? error;

  /// Signed in from the saved session while offline (limited mode).
  final bool startedOffline;

  @override
  List<Object?> get props => [
    status,
    user?.id,
    user?.name,
    isSubmitting,
    error,
    startedOffline,
  ];
}
