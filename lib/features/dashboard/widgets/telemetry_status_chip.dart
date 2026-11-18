import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';

/// Badge with the MQTT connection state.
class TelemetryStatusChip extends StatelessWidget {
  const TelemetryStatusChip({required this.status, super.key});

  final TelemetryStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TelemetryStatus.connected => ('Підключено', AppColors.online),
      TelemetryStatus.connecting => ('Підключення…', AppColors.pending),
      TelemetryStatus.disconnected => ('Відключено', AppColors.idle),
      TelemetryStatus.failed => ('Помилка', AppColors.offline),
    };

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
              label,
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
