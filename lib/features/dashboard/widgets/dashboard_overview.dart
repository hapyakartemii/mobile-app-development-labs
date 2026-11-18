import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';
import 'package:flutter_lab1/features/dashboard/widgets/current_weather_card.dart';
import 'package:flutter_lab1/features/dashboard/widgets/hourly_forecast_strip.dart';
import 'package:flutter_lab1/features/dashboard/widgets/sensor_tile.dart';
import 'package:flutter_lab1/features/shared/widgets/responsive_grid.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';

/// Weather forecast plus readings of the main (first) station.
class DashboardOverview extends StatelessWidget {
  const DashboardOverview({
    required this.forecast,
    required this.mainStation,
    super.key,
  });

  final WeatherForecast forecast;
  final WeatherStation? mainStation;

  @override
  Widget build(BuildContext context) {
    final station = mainStation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CurrentWeatherCard(conditions: forecast.current),
        const SectionHeader(title: 'Прогноз на сьогодні'),
        HourlyForecastStrip(items: forecast.hourly),
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
