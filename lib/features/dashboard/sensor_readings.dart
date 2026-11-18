import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';

/// One value prepared for display in a sensor tile.
class SensorReading {
  const SensorReading({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  /// Tile for [metric]; shows "—" until a value arrives.
  factory SensorReading.of(SensorMetric metric, double? value) {
    return SensorReading(
      label: metric.label,
      value: value == null ? '—' : metric.format(value),
      unit: metric.unit,
      icon: metric.icon,
    );
  }

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  /// Turns stored station metrics into tiles.
  static List<SensorReading> fromMetrics(StationMetrics metrics) => [
    SensorReading.of(SensorMetric.temperature, metrics.temperature),
    SensorReading.of(SensorMetric.humidity, metrics.humidity.toDouble()),
    SensorReading.of(SensorMetric.pressure, metrics.pressure.toDouble()),
    SensorReading.of(SensorMetric.wind, metrics.windSpeed),
  ];
}

/// Labels, units and icons live in the UI layer, so the domain stays
/// free of Flutter.
extension SensorMetricUi on SensorMetric {
  String get label => switch (this) {
    SensorMetric.temperature => 'Температура',
    SensorMetric.humidity => 'Вологість',
    SensorMetric.pressure => 'Тиск',
    SensorMetric.wind => 'Вітер',
  };

  String get unit => switch (this) {
    SensorMetric.temperature => '°C',
    SensorMetric.humidity => '%',
    SensorMetric.pressure => 'гПа',
    SensorMetric.wind => 'м/с',
  };

  IconData get icon => switch (this) {
    SensorMetric.temperature => Icons.thermostat,
    SensorMetric.humidity => Icons.water_drop_outlined,
    SensorMetric.pressure => Icons.speed,
    SensorMetric.wind => Icons.air,
  };

  /// Whole numbers for humidity and pressure, one decimal otherwise.
  String format(double value) => switch (this) {
    SensorMetric.humidity || SensorMetric.pressure => value.toStringAsFixed(0),
    _ => value.toStringAsFixed(1),
  };
}

extension WeatherConditionUi on WeatherCondition {
  IconData get icon => switch (this) {
    WeatherCondition.sunny => Icons.wb_sunny,
    WeatherCondition.partlyCloudy => Icons.wb_cloudy_outlined,
    WeatherCondition.cloudy => Icons.cloud,
    WeatherCondition.rain => Icons.grain,
  };

  String get label => switch (this) {
    WeatherCondition.sunny => 'Сонячно',
    WeatherCondition.partlyCloudy => 'Мінлива хмарність',
    WeatherCondition.cloudy => 'Хмарно',
    WeatherCondition.rain => 'Дощ',
  };
}
