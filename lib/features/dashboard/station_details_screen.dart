import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/app_config.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';
import 'package:flutter_lab1/features/dashboard/widgets/sensor_tile.dart';
import 'package:flutter_lab1/features/dashboard/widgets/station_info_card.dart';
import 'package:flutter_lab1/features/dashboard/widgets/station_topic_card.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';
import 'package:flutter_lab1/features/shared/widgets/responsive_grid.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';
import 'package:flutter_lab1/logic/stations/stations_cubit.dart';
import 'package:flutter_lab1/logic/stations/stations_state.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_cubit.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_state.dart';

/// One station with its MQTT topic and live values.
///
/// The station is read from the global [StationsState] by id, so values
/// that arrive over MQTT (applied by [StationsCubit]) appear here at once.
class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({required this.station, super.key});

  /// Station as it was when the screen opened; used if it's deleted.
  final WeatherStation station;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StationsCubit, StationsState, WeatherStation?>(
      selector: (state) => state.byId(station.id),
      builder: (context, current) {
        final shown = current ?? station;
        return Scaffold(
          appBar: AppBar(title: Text(shown.name)),
          body: PageBody(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!shown.isOnline) ...[
                  const NoticeBanner(
                    icon: Icons.warning_amber_rounded,
                    message: 'Станція офлайн. Показано останні отримані дані.',
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],
                StationInfoCard(station: shown),
                const SectionHeader(title: 'Датчики'),
                BlocBuilder<TelemetryCubit, TelemetryState>(
                  buildWhen: (previous, current) =>
                      previous.status != current.status,
                  builder: (context, telemetry) => StationTopicCard(
                    topic: AppConfig.stationTopic(shown.id),
                    status: telemetry.status,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                ResponsiveGrid(
                  children: [
                    for (final metric in SensorMetric.values)
                      SensorTile(
                        reading: SensorReading.of(
                          metric,
                          shown.metrics.valueOf(metric),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
