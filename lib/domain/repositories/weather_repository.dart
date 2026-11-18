import 'package:flutter_lab1/domain/entities/forecast.dart';

/// Source of the weather forecast (mock now, REST API in lab 5).
abstract interface class IWeatherRepository {
  Future<WeatherForecast> getForecast();
}
