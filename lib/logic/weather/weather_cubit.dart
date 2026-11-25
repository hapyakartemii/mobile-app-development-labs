import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';
import 'package:flutter_lab1/logic/weather/weather_state.dart';

/// Loads the forecast (network, or the cache when offline).
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._weather) : super(const WeatherState());

  final IWeatherRepository _weather;

  Future<void> load() async {
    emit(const WeatherState());
    try {
      final forecast = await _weather.getForecast();
      emit(WeatherState(status: WeatherStatus.loaded, forecast: forecast));
    } on WeatherException catch (error) {
      emit(WeatherState(status: WeatherStatus.failure, error: error.message));
    }
  }
}
