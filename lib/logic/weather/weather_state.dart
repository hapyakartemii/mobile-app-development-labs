import 'package:equatable/equatable.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';

enum WeatherStatus { loading, loaded, failure }

class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.loading,
    this.forecast,
    this.error,
  });

  final WeatherStatus status;
  final WeatherForecast? forecast;
  final String? error;

  @override
  List<Object?> get props => [status, forecast, error];
}
