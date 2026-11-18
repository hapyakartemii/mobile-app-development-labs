import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';

/// Inline error or warning, e.g. a failed login or an offline station.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({required this.message, super.key, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            spacing: AppSpacing.m,
            children: [
              Icon(icon ?? Icons.error_outline, color: scheme.onErrorContainer),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
