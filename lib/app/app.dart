import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';

class MeteoApp extends StatelessWidget {
  const MeteoApp({
    required this.authRepository,
    required this.stationRepository,
    required this.weatherRepository,
    super.key,
  });

  final IAuthRepository authRepository;
  final IStationRepository stationRepository;
  final IWeatherRepository weatherRepository;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      authRepository: authRepository,
      stationRepository: stationRepository,
      weatherRepository: weatherRepository,
      child: MaterialApp(
        title: 'Метеостанція',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.gate,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
