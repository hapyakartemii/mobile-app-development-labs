import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/features/shared/widgets/error_view.dart';

/// [FutureBuilder] with the app's three states:
/// * Loading — spinner while [future] runs;
/// * Error — [ErrorView] with "try again" ([onRetry]), or "log in" if the
///   session has expired;
/// * Success — whatever [builder] returns for the data.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    required this.future,
    required this.onRetry,
    required this.builder,
    super.key,
  });

  final Future<T> future;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.error case final error?) {
          if (error is AuthException) {
            return ErrorView(
              message: error.message,
              actionLabel: 'Увійти',
              onAction: () => AppRoutes.resetTo(context, AppRoutes.login),
            );
          }
          return ErrorView(
            message: ErrorView.messageOf(error),
            onAction: onRetry,
          );
        }
        return builder(context, snapshot.requireData);
      },
    );
  }
}
