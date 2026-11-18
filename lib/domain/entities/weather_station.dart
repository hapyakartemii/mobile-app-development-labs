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
  WeatherStation copyWith({String? name, String? location}) {
    return WeatherStation(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      isOnline: isOnline,
      battery: battery,
      updatedAt: updatedAt,
      metrics: metrics,
    );
  }
}

/// Fields the user enters when creating or editing a station.
class StationDraft {
  const StationDraft({required this.name, required this.location});

  final String name;
  final String location;
}
