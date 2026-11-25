import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';

/// Error state of a [FutureBuilder]: icon, message and an action button
/// (usually "try again") instead of a crash or an endless spinner.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    required this.onAction,
    super.key,
    this.actionLabel = 'Спробувати знову',
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  /// Text for any error a repository can throw; unknown ones get a
  /// generic message rather than a stack trace.
  static String messageOf(Object? error) => switch (error) {
    StationException(:final message) => message,
    AuthException(:final message) => message,
    WeatherException(:final message) => message,
    _ => 'Не вдалося завантажити дані. Спробуйте ще раз.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.m,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: theme.colorScheme.error,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              AppButton(
                label: actionLabel,
                icon: Icons.refresh,
                onPressed: onAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
