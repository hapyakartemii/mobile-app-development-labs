import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';
import 'package:flutter_lab1/features/dashboard/widgets/sensor_tile.dart';
import 'package:flutter_lab1/features/dashboard/widgets/status_chip.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/features/shared/widgets/info_tile.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';
import 'package:flutter_lab1/features/shared/widgets/responsive_grid.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';

/// Details of one station, opened from the dashboard with arguments.
class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({required this.station, super.key});

  final WeatherStation station;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(station.name)),
      body: PageBody(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!station.isOnline) ...[
              const NoticeBanner(
                icon: Icons.warning_amber_rounded,
                message: 'Станція офлайн. Показано останні отримані дані.',
              ),
              const SizedBox(height: AppSpacing.m),
            ],
            Card(
              child: Column(
                children: [
                  InfoTile(
                    icon: Icons.place_outlined,
                    label: 'Розташування',
                    value: station.location,
                  ),
                  ListTile(
                    leading: const Icon(Icons.wifi_tethering),
                    title: const Text('Стан'),
                    trailing: StatusChip(isOnline: station.isOnline),
                  ),
                  InfoTile(
                    icon: Icons.battery_std,
                    label: 'Батарея',
                    value: '${station.battery}%',
                  ),
                  InfoTile(
                    icon: Icons.update,
                    label: 'Останнє оновлення',
                    value: Formatters.relative(station.updatedAt),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Датчики'),
            ResponsiveGrid(
              children: [
                for (final reading in SensorReading.fromMetrics(
                  station.metrics,
                ))
                  SensorTile(reading: reading),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
