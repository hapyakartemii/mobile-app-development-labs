import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';

/// Horizontally scrollable list of hourly forecasts.
class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({required this.items, super.key});

  static const double height = 116;

  final List<HourlyForecast> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (_, index) => _ForecastItem(item: items[index]),
      ),
    );
  }
}

class _ForecastItem extends StatelessWidget {
  const _ForecastItem({required this.item});

  final HourlyForecast item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 76,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.time, style: theme.textTheme.bodySmall),
              Icon(item.condition.icon, color: theme.colorScheme.primary),
              Text('${item.temperature}°', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
