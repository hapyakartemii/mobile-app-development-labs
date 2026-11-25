import 'package:flutter_lab1/data/cache/station_cache.dart';
import 'package:flutter_lab1/data/remote/api_exception.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';

/// Offline-first [IStationRepository]: wraps the network one with a cache.
///
/// Reading: network → save to cache → return. No internet or server
/// unreachable → return the cached list instead of an error.
/// Changes need the network (editing offline isn't required); on success
/// the cache is updated too.
class CachedStationRepository implements IStationRepository {
  CachedStationRepository({
    required this._remote,
    required this._cache,
    required this._connectivity,
  });

  static const _offline =
      'Немає інтернету. Змінювати станції можна лише онлайн.';
  static const _serverDown = 'Сервер недоступний. Спробуйте пізніше.';

  final IStationRepository _remote;
  final StationCache _cache;
  final IConnectivityService _connectivity;

  @override
  Future<List<WeatherStation>> getStations(String userId) async {
    if (!await _connectivity.isOnline()) return _cache.read(userId);
    try {
      final stations = await _remote.getStations(userId);
      await _cache.write(userId, stations);
      return stations;
    } on ApiException {
      return _cache.read(userId);
    }
  }

  @override
  Future<WeatherStation> createStation(String userId, StationDraft draft) =>
      _online(() async {
        final station = await _remote.createStation(userId, draft);
        await _cache.upsert(userId, station);
        return station;
      });

  @override
  Future<WeatherStation> updateStation(
    String userId,
    String stationId,
    StationDraft draft,
  ) => _online(() async {
    final station = await _remote.updateStation(userId, stationId, draft);
    await _cache.upsert(userId, station);
    return station;
  });

  @override
  Future<void> deleteStation(String userId, String stationId) =>
      _online(() async {
        await _remote.deleteStation(userId, stationId);
        await _cache.remove(userId, stationId);
      });

  /// MQTT values are cached right away and sent to the server when it's
  /// reachable; a lost update is fine, the next reading replaces it.
  @override
  Future<void> saveLiveData(String userId, WeatherStation station) async {
    await _cache.upsert(userId, station);
    try {
      await _remote.saveLiveData(userId, station);
    } on ApiException {
      // Server unreachable: the value stays in the cache.
    } on StationException {
      // Rejected (e.g. station deleted meanwhile): nothing to send.
    }
  }

  Future<T> _online<T>(Future<T> Function() action) async {
    if (!await _connectivity.isOnline()) {
      throw const StationException(_offline);
    }
    try {
      return await action();
    } on ApiException {
      throw const StationException(_serverDown);
    }
  }
}
