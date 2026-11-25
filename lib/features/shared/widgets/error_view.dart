import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';

/// Error state of a screen: icon, message and an action button
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
