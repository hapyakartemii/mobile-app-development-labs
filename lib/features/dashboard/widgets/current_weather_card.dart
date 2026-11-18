import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';

/// Hero card with the current temperature and today's range.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({required this.conditions, super.key});

  final CurrentConditions conditions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onColor = scheme.onPrimary;
    final textTheme = theme.textTheme.apply(
      bodyColor: onColor,
      displayColor: onColor,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s,
          children: [
            Row(
              spacing: AppSpacing.xs,
              children: [
                Icon(Icons.place_outlined, color: onColor, size: 18),
                Expanded(
                  child: Text(
                    conditions.location,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${conditions.temperature}°',
                      style: textTheme.displayLarge,
                    ),
                  ),
                ),
                Icon(conditions.condition.icon, color: onColor, size: 64),
              ],
            ),
            Text(conditions.condition.label, style: textTheme.titleMedium),
            Text(
              'Відчувається як ${conditions.feelsLike}° · '
              'Макс. ${conditions.high}° · Мін. ${conditions.low}°',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
