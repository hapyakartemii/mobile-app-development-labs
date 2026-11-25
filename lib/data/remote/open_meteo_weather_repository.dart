import 'dart:convert';

import 'package:flutter_lab1/app/app_config.dart';
import 'package:flutter_lab1/data/remote/api_client.dart';
import 'package:flutter_lab1/data/remote/api_exception.dart';
import 'package:flutter_lab1/data/remote/dto/forecast_dto.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [IWeatherRepository] over the public Open-Meteo REST API, offline-first:
/// every successful reply is cached; without the internet (or if the API
/// fails) the last cached forecast is returned.
class OpenMeteoWeatherRepository implements IWeatherRepository {
  const OpenMeteoWeatherRepository({
    required this._api,
    required this._prefs,
    required this._connectivity,
  });

  static const _cacheKey = 'cache.forecast';

  final ApiClient _api;
  final SharedPreferences _prefs;
  final IConnectivityService _connectivity;

  @override
  Future<WeatherForecast> getForecast() async {
    if (await _connectivity.isOnline()) {
      try {
        final json = ApiClient.objectOf(
          await _api.get('/v1/forecast', query: _query),
        );
        await _prefs.setString(_cacheKey, jsonEncode(json));
        return _parse(json);
      } on ApiException {
        // Fall through to the cache.
      }
    }
    final cached = _prefs.getString(_cacheKey);
    if (cached == null) {
      throw const WeatherException(
        'Прогноз недоступний: немає інтернету і збережених даних.',
      );
    }
    return _parse(jsonDecode(cached) as Map<String, dynamic>);
  }

  static WeatherForecast _parse(Map<String, dynamic> json) =>
      ForecastDto.fromJson(json).toEntity(AppConfig.weatherLocation);

  static const _query = {
    'latitude': AppConfig.weatherLatitude,
    'longitude': AppConfig.weatherLongitude,
    'current': 'temperature_2m,apparent_temperature,weather_code',
    'hourly': 'temperature_2m,weather_code',
    'daily': 'temperature_2m_max,temperature_2m_min',
    'timezone': 'auto',
    'forecast_days': 2,
  };
}
