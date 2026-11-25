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
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/session_storage.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';
import 'package:flutter_lab1/domain/services/telemetry_service.dart';
import 'package:flutter_lab1/logic/auth/auth_cubit.dart';
import 'package:flutter_lab1/logic/connectivity/connectivity_cubit.dart';
import 'package:flutter_lab1/logic/stations/stations_cubit.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_cubit.dart';
import 'package:flutter_lab1/logic/weather/weather_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's DI container (service locator).
final getIt = GetIt.instance;

/// Registers every dependency once, at start-up — the only place that
/// knows concrete classes.
///
/// * Services and repositories are **singletons** (`registerLazySingleton`):
///   created on first use and then shared for the whole app lifetime.
/// * Cubits are **factories** (`registerFactory`): each `BlocProvider`
///   gets a fresh one, built from those singletons.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<ISessionStorage>(SecureSessionStorage.new)
    ..registerLazySingleton<IConnectivityService>(
      () => ConnectivityPlusService(probeHost: AppConfig.connectivityProbeHost),
    )
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(baseUrl: AppConfig.apiBaseUrl, sessions: getIt()),
    )
    ..registerLazySingleton<IAuthRepository>(
      () => RemoteAuthRepository(
        api: getIt(),
        sessions: getIt(),
        profileCache: ProfileCache(getIt()),
      ),
    )
    ..registerLazySingleton<IStationRepository>(
      () => CachedStationRepository(
        remote: RemoteStationRepository(getIt()),
        cache: StationCache(getIt()),
        connectivity: getIt(),
      ),
    )
    // Weather uses its own client: another server and no JWT header.
    ..registerLazySingleton<IWeatherRepository>(
      () => OpenMeteoWeatherRepository(
        api: ApiClient(baseUrl: AppConfig.weatherBaseUrl),
        prefs: getIt(),
        connectivity: getIt(),
      ),
    )
    ..registerLazySingleton<ITelemetryService>(
      () => MqttTelemetryService(
        host: AppConfig.mqttHost,
        port: AppConfig.mqttPort,
        topic: AppConfig.mqttTopic,
      ),
    )
    ..registerFactory(() => AuthCubit(getIt(), getIt()))
    ..registerFactory(() => ConnectivityCubit(getIt()))
    ..registerFactory(() => StationsCubit(getIt(), getIt()))
    ..registerFactory(() => TelemetryCubit(getIt(), getIt()))
    ..registerFactory(() => WeatherCubit(getIt()));
}
