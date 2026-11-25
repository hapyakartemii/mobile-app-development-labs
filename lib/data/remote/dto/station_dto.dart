import 'package:flutter_lab1/domain/entities/weather_station.dart';

/// Station as the API sends it (`metrics` is a nested object).
class StationDto {
  const StationDto({
    required this.id,
    required this.name,
    required this.location,
    required this.isOnline,
    required this.battery,
    required this.updatedAt,
    required this.metrics,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) => StationDto(
    id: json['id'] as String,
    name: json['name'] as String,
    location: json['location'] as String,
    isOnline: json['isOnline'] as bool,
    battery: json['battery'] as int,
    updatedAt: json['updatedAt'] as String,
    metrics: json['metrics'] as Map<String, dynamic>,
  );

  factory StationDto.fromEntity(WeatherStation station) => StationDto(
    id: station.id,
    name: station.name,
    location: station.location,
    isOnline: station.isOnline,
    battery: station.battery,
    updatedAt: station.updatedAt.toIso8601String(),
    metrics: metricsToJson(station.metrics),
  );

  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final int battery;
  final String updatedAt;
  final Map<String, dynamic> metrics;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'isOnline': isOnline,
    'battery': battery,
    'updatedAt': updatedAt,
    'metrics': metrics,
  };

  /// Body of `PATCH /stations/{id}/live`: only what MQTT changes.
  Map<String, Object> toLiveJson() => {
    'isOnline': isOnline,
    'updatedAt': updatedAt,
    'metrics': metrics,
  };

  WeatherStation toEntity() => WeatherStation(
    id: id,
    name: name,
    location: location,
    isOnline: isOnline,
    battery: battery,
    updatedAt: DateTime.parse(updatedAt),
    metrics: StationMetrics(
      // `num` first: JSON may send 18.0 as 18.
      temperature: (metrics['temperature'] as num).toDouble(),
      humidity: (metrics['humidity'] as num).round(),
      pressure: (metrics['pressure'] as num).round(),
      windSpeed: (metrics['windSpeed'] as num).toDouble(),
    ),
  );

  static Map<String, Object> metricsToJson(StationMetrics metrics) => {
    'temperature': metrics.temperature,
    'humidity': metrics.humidity,
    'pressure': metrics.pressure,
    'windSpeed': metrics.windSpeed,
  };
}
