import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app.dart';
import 'package:flutter_lab1/data/local/shared_prefs_auth_repository.dart';
import 'package:flutter_lab1/data/local/shared_prefs_station_repository.dart';
import 'package:flutter_lab1/data/mock/mock_weather.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root: the only place that knows the concrete storage.
/// Moving to a REST API means swapping these implementations here.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  const latency = Duration(milliseconds: 500);

  runApp(
    MeteoApp(
      authRepository: SharedPrefsAuthRepository(prefs, latency: latency),
      stationRepository: SharedPrefsStationRepository(prefs, latency: latency),
      weatherRepository: const MockWeatherRepository(),
    ),
  );
}
