import 'package:flutter_lab1/domain/entities/forecast.dart';

/// Source of the weather forecast.
abstract interface class IWeatherRepository {
  /// Throws [WeatherException] if no forecast can be shown at all.
  Future<WeatherForecast> getForecast();
}

/// Forecast unavailable, with a message safe to show to the user.
class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => 'WeatherException: $message';
}
