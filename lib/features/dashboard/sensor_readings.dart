import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';

/// One value prepared for display in a sensor tile.
class SensorReading {
  const SensorReading({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  /// Turns raw station metrics into tiles. Keeps icons and units in the
  /// UI layer, so the domain stays free of Flutter.
  static List<SensorReading> fromMetrics(StationMetrics metrics) => [
    SensorReading(
      label: 'Температура',
      value: metrics.temperature.toStringAsFixed(1),
      unit: '°C',
      icon: Icons.thermostat,
    ),
    SensorReading(
      label: 'Вологість',
      value: '${metrics.humidity}',
      unit: '%',
      icon: Icons.water_drop_outlined,
    ),
    SensorReading(
      label: 'Тиск',
      value: '${metrics.pressure}',
      unit: 'гПа',
      icon: Icons.speed,
    ),
    SensorReading(
      label: 'Вітер',
      value: metrics.windSpeed.toStringAsFixed(1),
      unit: 'м/с',
      icon: Icons.air,
    ),
  ];
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
