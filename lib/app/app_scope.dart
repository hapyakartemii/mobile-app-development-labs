import 'package:flutter/widgets.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';
import 'package:flutter_lab1/domain/services/telemetry_service.dart';

/// Makes repositories and services available to every screen.
///
/// Fields are typed with the abstractions, so screens never know which
/// storage, network check or protocol is used underneath.
class AppScope extends InheritedWidget {
  const AppScope({
    required this.authRepository,
    required this.stationRepository,
    required this.weatherRepository,
    required this.connectivityService,
    required this.telemetryService,
    required super.child,
    super.key,
  });

  final IAuthRepository authRepository;
  final IStationRepository stationRepository;
  final IWeatherRepository weatherRepository;
  final IConnectivityService connectivityService;
  final ITelemetryService telemetryService;

  /// Safe to call from `initState`: doesn't subscribe to changes,
  /// the dependencies are fixed for the app's lifetime.
  static AppScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      authRepository != oldWidget.authRepository ||
      stationRepository != oldWidget.stationRepository ||
      weatherRepository != oldWidget.weatherRepository ||
      connectivityService != oldWidget.connectivityService ||
      telemetryService != oldWidget.telemetryService;
}
