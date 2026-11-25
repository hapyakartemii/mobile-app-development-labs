import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app.dart';
import 'package:flutter_lab1/app/app_config.dart';
import 'package:flutter_lab1/data/cache/cached_station_repository.dart';
import 'package:flutter_lab1/data/cache/profile_cache.dart';
import 'package:flutter_lab1/data/cache/station_cache.dart';
import 'package:flutter_lab1/data/local/secure_session_storage.dart';
import 'package:flutter_lab1/data/network/connectivity_plus_service.dart';
import 'package:flutter_lab1/data/remote/api_client.dart';
import 'package:flutter_lab1/data/remote/open_meteo_weather_repository.dart';
import 'package:flutter_lab1/data/remote/remote_auth_repository.dart';
import 'package:flutter_lab1/data/remote/remote_station_repository.dart';
import 'package:flutter_lab1/data/telemetry/mqtt_telemetry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: the only place that knows the concrete classes.
///
/// Lab 5 swapped local storage for the REST API right here: screens still
/// get the same IAuthRepository / IStationRepository / IWeatherRepository.
/// Going back to local-only means passing SharedPrefsAuthRepository and
/// SharedPrefsStationRepository instead.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final sessions = SecureSessionStorage();
  final connectivity = ConnectivityPlusService(
    probeHost: AppConfig.connectivityProbeHost,
  );
  final api = ApiClient(baseUrl: AppConfig.apiBaseUrl, sessions: sessions);

  runApp(
    MeteoApp(
      authRepository: RemoteAuthRepository(
        api: api,
        sessions: sessions,
        profileCache: ProfileCache(prefs),
      ),
      stationRepository: CachedStationRepository(
        remote: RemoteStationRepository(api),
        cache: StationCache(prefs),
        connectivity: connectivity,
      ),
      weatherRepository: OpenMeteoWeatherRepository(
        api: ApiClient(baseUrl: AppConfig.weatherBaseUrl),
        prefs: prefs,
        connectivity: connectivity,
      ),
      connectivityService: connectivity,
      telemetryService: MqttTelemetryService(
        host: AppConfig.mqttHost,
        port: AppConfig.mqttPort,
        topic: AppConfig.mqttTopic,
      ),
    ),
  );
}
