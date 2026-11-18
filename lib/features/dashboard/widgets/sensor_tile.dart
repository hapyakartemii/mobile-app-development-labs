import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';

/// Card with one sensor value: icon, label, value and unit.
class SensorTile extends StatelessWidget {
  const SensorTile({required this.reading, super.key});

  final SensorReading reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: scheme.primaryContainer,
              child: Icon(reading.icon, color: scheme.onPrimaryContainer),
            ),
            Text(
              reading.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: reading.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: ' ${reading.unit}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
