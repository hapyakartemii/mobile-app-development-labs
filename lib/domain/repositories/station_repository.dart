import 'package:flutter_lab1/domain/entities/weather_station.dart';

/// CRUD contract for a user's weather stations.
abstract interface class IStationRepository {
  Future<List<WeatherStation>> getStations(String userId);

  Future<WeatherStation> createStation(String userId, StationDraft draft);

  /// Throws [StationException] if the station doesn't exist.
  Future<WeatherStation> updateStation(
    String userId,
    String stationId,
    StationDraft draft,
  );

  /// Throws [StationException] if the station doesn't exist.
  Future<void> deleteStation(String userId, String stationId);
}

/// Expected station failure with a message safe to show to the user.
class StationException implements Exception {
  const StationException(this.message);

  final String message;

  @override
  String toString() => 'StationException: $message';
}
