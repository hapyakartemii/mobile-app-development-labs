import 'dart:math';

import 'package:flutter_lab1/domain/entities/weather_station.dart';

/// Generates plausible readings for a newly added station until real
/// devices are connected over MQTT (lab 4).
class SensorSimulator {
  SensorSimulator([Random? random]) : _random = random ?? Random();

  final Random _random;

  StationMetrics next() => StationMetrics(
    temperature: _oneDecimal(8 + _random.nextDouble() * 16),
    humidity: 40 + _random.nextInt(45),
    pressure: 1000 + _random.nextInt(25),
    windSpeed: _oneDecimal(_random.nextDouble() * 9),
  );

  static double _oneDecimal(double value) => (value * 10).round() / 10;
}
