import 'package:flutter_lab1/domain/entities/telemetry.dart';

/// Latest values measured by a station.
class StationMetrics {
  const StationMetrics({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
  });

  /// °C
  final double temperature;

  /// %
  final int humidity;

  /// hPa
  final int pressure;

  /// m/s
  final double windSpeed;

  double valueOf(SensorMetric metric) => switch (metric) {
    SensorMetric.temperature => temperature,
    SensorMetric.humidity => humidity.toDouble(),
    SensorMetric.pressure => pressure.toDouble(),
    SensorMetric.wind => windSpeed,
  };

  /// Returns new metrics with [metric] replaced; the others stay the same.
  StationMetrics withValue(SensorMetric metric, double value) {
    return StationMetrics(
      temperature: metric == SensorMetric.temperature ? value : temperature,
      humidity: metric == SensorMetric.humidity ? value.round() : humidity,
      pressure: metric == SensorMetric.pressure ? value.round() : pressure,
      windSpeed: metric == SensorMetric.wind ? value : windSpeed,
    );
  }
}

/// IoT weather station owned by a user.
class WeatherStation {
  const WeatherStation({
    required this.id,
    required this.name,
    required this.location,
    required this.isOnline,
    required this.battery,
    required this.updatedAt,
    required this.metrics,
  });

  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final int battery;
  final DateTime updatedAt;
  final StationMetrics metrics;

  /// Returns a new station; the original stays unchanged.
  WeatherStation copyWith({
    String? name,
    String? location,
    bool? isOnline,
    DateTime? updatedAt,
    StationMetrics? metrics,
  }) {
    return WeatherStation(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      battery: battery,
      updatedAt: updatedAt ?? this.updatedAt,
      metrics: metrics ?? this.metrics,
    );
  }

  /// Station after a live MQTT [reading]: that value replaced, marked
  /// online and updated at the time the reading arrived.
  WeatherStation withReading(TelemetryReading reading) => copyWith(
    isOnline: true,
    updatedAt: reading.receivedAt,
    metrics: metrics.withValue(reading.metric, reading.value),
  );
}

/// Fields the user enters when creating or editing a station.
class StationDraft {
  const StationDraft({required this.name, required this.location});

  final String name;
  final String location;
}
