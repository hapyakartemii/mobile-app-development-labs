import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';
import 'package:flutter_lab1/features/dashboard/widgets/live_telemetry_section.dart';
import 'package:flutter_lab1/features/dashboard/widgets/sensor_tile.dart';
import 'package:flutter_lab1/features/dashboard/widgets/weather_section.dart';
import 'package:flutter_lab1/features/shared/widgets/responsive_grid.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';

/// Weather forecast, MQTT broker card and readings of the main (first)
/// station.
class DashboardOverview extends StatelessWidget {
  const DashboardOverview({
    required this.refreshCount,
    required this.mainStation,
    super.key,
  });

  /// Changes on "refresh"; used as the forecast's key to reload it.
  final int refreshCount;
  final WeatherStation? mainStation;

  @override
  Widget build(BuildContext context) {
    final station = mainStation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeatherSection(key: ValueKey(refreshCount)),
        const SectionHeader(title: 'MQTT-брокер'),
        const LiveTelemetrySection(),
        if (station != null) ...[
          SectionHeader(title: 'Показники: ${station.name}'),
          ResponsiveGrid(
            children: [
              for (final reading in SensorReading.fromMetrics(station.metrics))
                SensorTile(reading: reading),
            ],
          ),
        ],
      ],
    );
  }
}
