import 'package:flutter/widgets.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';

/// Makes the repositories available to every screen.
///
/// Fields are typed with the abstractions, so screens never know which
/// storage is used underneath.
class AppScope extends InheritedWidget {
  const AppScope({
    required this.authRepository,
    required this.stationRepository,
    required this.weatherRepository,
    required super.child,
    super.key,
  });

  final IAuthRepository authRepository;
  final IStationRepository stationRepository;
  final IWeatherRepository weatherRepository;

  /// Safe to call from `initState`: doesn't subscribe to changes,
  /// the repositories are fixed for the app's lifetime.
  static AppScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      authRepository != oldWidget.authRepository ||
      stationRepository != oldWidget.stationRepository ||
      weatherRepository != oldWidget.weatherRepository;
}
