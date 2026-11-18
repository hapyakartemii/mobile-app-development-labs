import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_config.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/live_telemetry_controller.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';
import 'package:flutter_lab1/features/dashboard/widgets/sensor_tile.dart';
import 'package:flutter_lab1/features/dashboard/widgets/station_topic_card.dart';
import 'package:flutter_lab1/features/dashboard/widgets/status_chip.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/features/shared/widgets/info_tile.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';
import 'package:flutter_lab1/features/shared/widgets/responsive_grid.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';
import 'package:provider/provider.dart';

/// Details of one station with its own MQTT topic and live values.
///
/// Values sent to `meteo/hapyakartemii/<id>/<metric>` replace the stored
/// ones as they arrive. The connection itself belongs to the dashboard
/// underneath, so this screen only listens to it.
class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({required this.station, super.key});

  final WeatherStation station;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ChangeNotifierProvider(
      create: (_) => LiveTelemetryController(
        telemetry: scope.telemetryService,
        connectivity: scope.connectivityService,
        stationId: station.id,
        managesConnection: false,
      )..start(),
      child: _StationDetailsView(station: station),
    );
  }
}

class _StationDetailsView extends StatelessWidget {
  const _StationDetailsView({required this.station});

  final WeatherStation station;

  @override
  Widget build(BuildContext context) {
    final live = context.watch<LiveTelemetryController>();
    final isOnline = live.lastMessageAt != null || station.isOnline;
    final updatedAt = live.lastMessageAt ?? station.updatedAt;

    return Scaffold(
      appBar: AppBar(title: Text(station.name)),
      body: PageBody(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isOnline) ...[
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
                    trailing: StatusChip(isOnline: isOnline),
                  ),
                  InfoTile(
                    icon: Icons.battery_std,
                    label: 'Батарея',
                    value: '${station.battery}%',
                  ),
                  InfoTile(
                    icon: Icons.update,
                    label: 'Останнє оновлення',
                    value: Formatters.relative(updatedAt),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Датчики'),
            StationTopicCard(
              topic: AppConfig.stationTopic(station.id),
              status: live.status,
            ),
            const SizedBox(height: AppSpacing.m),
            ResponsiveGrid(
              children: [
                for (final metric in SensorMetric.values)
                  SensorTile(
                    reading: SensorReading.of(
                      metric,
                      live.latest(metric)?.value ??
                          station.metrics.valueOf(metric),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
