import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/data/local/shared_prefs_auth_repository.dart';
import 'package:flutter_lab1/data/local/shared_prefs_station_repository.dart';
import 'package:flutter_lab1/data/mock/mock_weather.dart';
import 'package:flutter_lab1/data/mock/sensor_simulator.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testName = "Артемій Гап'як";
const testEmail = 'artem@example.com';
const testPassword = 'secret123';

/// Real repositories over an in-memory SharedPreferences, no latency.
class TestDeps {
  TestDeps._(this.prefs)
    : auth = SharedPrefsAuthRepository(prefs),
      stations = SharedPrefsStationRepository(
        prefs,
        simulator: SensorSimulator(Random(1)),
      );

  final SharedPreferences prefs;
  final SharedPrefsAuthRepository auth;
  final SharedPrefsStationRepository stations;

  static Future<TestDeps> create() async {
    SharedPreferences.setMockInitialValues({});
    return TestDeps._(await SharedPreferences.getInstance());
  }

  Future<AppUser> signUp() =>
      auth.register(name: testName, email: testEmail, password: testPassword);

  /// The whole app, starting from the session check.
  Widget app() => MeteoApp(
    authRepository: auth,
    stationRepository: stations,
    weatherRepository: const MockWeatherRepository(),
  );

  /// A single screen with routing and repositories available.
  Widget screen(Widget home) => AppScope(
    authRepository: auth,
    stationRepository: stations,
    weatherRepository: const MockWeatherRepository(),
    child: MaterialApp(
      theme: AppTheme.light,
      home: home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    ),
  );
}
