import 'package:flutter_lab1/data/local/json_list_store.dart';
import 'package:flutter_lab1/data/local/station_json.dart';
import 'package:flutter_lab1/data/mock/sensor_simulator.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [IStationRepository] backed by SharedPreferences: each user's stations
/// are a JSON list under their own key.
class SharedPrefsStationRepository implements IStationRepository {
  SharedPrefsStationRepository(
    SharedPreferences prefs, {
    Duration latency = Duration.zero,
    SensorSimulator? simulator,
  }) : _store = JsonListStore(prefs, latency: latency),
       _simulator = simulator ?? SensorSimulator();

  static const _notFound = 'Станцію не знайдено';

  final JsonListStore _store;
  final SensorSimulator _simulator;

  static String keyFor(String userId) => 'stations.$userId';

  @override
  Future<List<WeatherStation>> getStations(String userId) async {
    final items = await _store.read(keyFor(userId));
    return [for (final json in items) StationJson.decode(json)];
  }

  @override
  Future<WeatherStation> createStation(
    String userId,
    StationDraft draft,
  ) async {
    _validate(draft);
    final stations = await getStations(userId);
    final station = WeatherStation(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      name: draft.name.trim(),
      location: draft.location.trim(),
      isOnline: true,
      battery: 100,
      updatedAt: DateTime.now(),
      metrics: _simulator.next(),
    );
    await _save(userId, [...stations, station]);
    return station;
  }

  @override
  Future<WeatherStation> updateStation(
    String userId,
    String stationId,
    StationDraft draft,
  ) async {
    _validate(draft);
    final stations = await getStations(userId);
    final index = stations.indexWhere((station) => station.id == stationId);
    if (index == -1) throw const StationException(_notFound);

    final updated = stations[index].copyWith(
      name: draft.name.trim(),
      location: draft.location.trim(),
    );
    await _save(userId, [...stations]..[index] = updated);
    return updated;
  }

  @override
  Future<void> deleteStation(String userId, String stationId) async {
    final stations = await getStations(userId);
    final remaining = [
      for (final station in stations)
        if (station.id != stationId) station,
    ];
    if (remaining.length == stations.length) {
      throw const StationException(_notFound);
    }
    await _save(userId, remaining);
  }

  Future<void> _save(String userId, List<WeatherStation> stations) =>
      _store.write(keyFor(userId), [
        for (final station in stations) StationJson.encode(station),
      ]);

  static void _validate(StationDraft draft) {
    final error = Validators.firstError([
      Validators.stationName(draft.name),
      Validators.location(draft.location),
    ]);
    if (error != null) throw StationException(error);
  }
}
