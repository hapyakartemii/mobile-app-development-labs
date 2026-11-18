import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';

/// Avatar with initials, name and email.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      spacing: AppSpacing.s,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: scheme.primaryContainer,
          child: Text(
            user.initials,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
