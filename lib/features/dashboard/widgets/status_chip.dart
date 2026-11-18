import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';

/// Small "Online" / "Offline" badge with a colored dot.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.isOnline, super.key});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.online : AppColors.offline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            Icon(Icons.circle, size: 8, color: color),
            Text(
              isOnline ? 'Онлайн' : 'Офлайн',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
