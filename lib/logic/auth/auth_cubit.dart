import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';
import 'package:flutter_lab1/logic/auth/auth_state.dart';

/// Session logic: auto-login, login, registration, logout.
///
/// Screens only call these methods and draw [AuthState]; they never touch
/// the repository or the network themselves.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._auth, this._connectivity) : super(const AuthState());

  static const noInternet =
      'Немає підключення до інтернету. Перевірте Wi-Fi або мобільні дані.';

  final IAuthRepository _auth;
  final IConnectivityService _connectivity;

  /// Auto-login at start: restores the saved session (works offline).
  Future<void> checkSession() async {
    final user = await _auth.currentUser();
    if (user == null) {
      return emit(const AuthState(status: AuthStatus.unauthenticated));
    }
    final isOnline = await _connectivity.isOnline();
    emit(
      AuthState(
        status: AuthStatus.authenticated,
        user: user,
        startedOffline: !isOnline,
      ),
    );
  }

  Future<void> login({required String email, required String password}) =>
      _submit(() => _auth.login(email: email, password: password));

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) => _submit(
    () => _auth.register(name: name, email: email, password: password),
  );

  Future<void> logout() async {
    emit(AuthState(status: state.status, user: state.user, isSubmitting: true));
    await _auth.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Hides the previous form error when a form opens.
  void clearError() {
    if (state.error != null) emit(AuthState(status: state.status));
  }

  Future<void> _submit(Future<AppUser> Function() request) async {
    emit(
      const AuthState(status: AuthStatus.unauthenticated, isSubmitting: true),
    );
    if (!await _connectivity.isOnline()) {
      return emit(
        const AuthState(status: AuthStatus.unauthenticated, error: noInternet),
      );
    }
    try {
      final user = await request();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (error) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: error.message));
    }
  }
}
