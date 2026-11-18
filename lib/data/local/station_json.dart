import 'package:flutter_lab1/domain/entities/weather_station.dart';

/// Converts [WeatherStation] to and from the JSON stored on the device.
abstract final class StationJson {
  static Map<String, Object> encode(WeatherStation station) => {
    'id': station.id,
    'name': station.name,
    'location': station.location,
    'isOnline': station.isOnline,
    'battery': station.battery,
    'updatedAt': station.updatedAt.toIso8601String(),
    'metrics': {
      'temperature': station.metrics.temperature,
      'humidity': station.metrics.humidity,
      'pressure': station.metrics.pressure,
      'windSpeed': station.metrics.windSpeed,
    },
  };

  static WeatherStation decode(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>;
    return WeatherStation(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      isOnline: json['isOnline'] as bool,
      battery: json['battery'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metrics: StationMetrics(
        temperature: (metrics['temperature'] as num).toDouble(),
        humidity: metrics['humidity'] as int,
        pressure: metrics['pressure'] as int,
        windSpeed: (metrics['windSpeed'] as num).toDouble(),
      ),
    );
  }
}
