import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app.dart';
import 'package:flutter_lab1/app/app_config.dart';
import 'package:flutter_lab1/data/local/secure_session_storage.dart';
import 'package:flutter_lab1/data/local/shared_prefs_auth_repository.dart';
import 'package:flutter_lab1/data/local/shared_prefs_station_repository.dart';
import 'package:flutter_lab1/data/mock/mock_weather.dart';
import 'package:flutter_lab1/data/network/connectivity_plus_service.dart';
import 'package:flutter_lab1/data/telemetry/mqtt_telemetry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: the only place that knows the concrete storage,
/// network check and IoT protocol. Swapping one means editing only here.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  const latency = Duration(milliseconds: 500);

  runApp(
    MeteoApp(
      authRepository: SharedPrefsAuthRepository(
        prefs,
        SecureSessionStorage(),
        latency: latency,
      ),
      stationRepository: SharedPrefsStationRepository(prefs, latency: latency),
      weatherRepository: const MockWeatherRepository(),
      connectivityService: ConnectivityPlusService(
        probeHost: AppConfig.connectivityProbeHost,
      ),
      telemetryService: MqttTelemetryService(
        host: AppConfig.mqttHost,
        port: AppConfig.mqttPort,
        topic: AppConfig.mqttTopic,
      ),
    ),
  );
}
