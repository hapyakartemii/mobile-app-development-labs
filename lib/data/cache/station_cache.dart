import 'package:flutter_lab1/data/local/json_list_store.dart';
import 'package:flutter_lab1/data/local/station_json.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local copy of the stations last received from the server.
class StationCache {
  StationCache(SharedPreferences prefs) : _store = JsonListStore(prefs);

  final JsonListStore _store;

  static String _key(String userId) => 'cache.stations.$userId';

  Future<List<WeatherStation>> read(String userId) async => [
    for (final json in await _store.read(_key(userId)))
      StationJson.decode(json),
  ];

  /// Replaces the whole cached list (after a successful download).
  Future<void> write(String userId, List<WeatherStation> stations) =>
      _store.write(_key(userId), [
        for (final station in stations) StationJson.encode(station),
      ]);

  /// Adds [station] or replaces the cached one with the same id.
  Future<void> upsert(String userId, WeatherStation station) async {
    final stations = await read(userId);
    final index = stations.indexWhere((cached) => cached.id == station.id);
    await write(
      userId,
      index == -1 ? [...stations, station] : ([...stations]..[index] = station),
    );
  }

  Future<void> remove(String userId, String stationId) async {
    final stations = await read(userId);
    await write(userId, [
      for (final station in stations)
        if (station.id != stationId) station,
    ]);
  }
}
