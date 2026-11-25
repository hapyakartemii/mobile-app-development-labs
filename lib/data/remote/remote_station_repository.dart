import 'package:flutter_lab1/data/remote/api_client.dart';
import 'package:flutter_lab1/data/remote/api_exception.dart';
import 'package:flutter_lab1/data/remote/dto/station_dto.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';

/// [IStationRepository] over the REST API.
///
/// The server knows the user from the JWT, so `userId` isn't sent.
/// HTTP errors become [StationException]; network errors are rethrown as
/// [ApiException] so [CachedStationRepository] can fall back to the cache.
class RemoteStationRepository implements IStationRepository {
  const RemoteStationRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<WeatherStation>> getStations(String userId) async {
    final data = await _call(() => _api.get('/stations'));
    return [
      for (final json in ApiClient.listOf(data))
        StationDto.fromJson(json).toEntity(),
    ];
  }

  @override
  Future<WeatherStation> createStation(String userId, StationDraft draft) =>
      _station(() => _api.post('/stations', _draftJson(draft)));

  @override
  Future<WeatherStation> updateStation(
    String userId,
    String stationId,
    StationDraft draft,
  ) => _station(() => _api.put('/stations/$stationId', _draftJson(draft)));

  @override
  Future<void> deleteStation(String userId, String stationId) =>
      _call(() => _api.delete('/stations/$stationId'));

  @override
  Future<void> saveLiveData(String userId, WeatherStation station) => _call(
    () => _api.patch(
      '/stations/${station.id}/live',
      StationDto.fromEntity(station).toLiveJson(),
    ),
  );

  Future<WeatherStation> _station(Future<Object?> Function() request) async {
    final data = await _call(request);
    return StationDto.fromJson(ApiClient.objectOf(data)).toEntity();
  }

  static Map<String, Object> _draftJson(StationDraft draft) => {
    'name': draft.name.trim(),
    'location': draft.location.trim(),
  };

  /// Runs a request; turns server errors into [StationException].
  Future<Object?> _call(Future<Object?> Function() request) async {
    try {
      return await request();
    } on ApiException catch (error) {
      if (error.isNetworkError) rethrow;
      throw StationException(error.message);
    }
  }
}
