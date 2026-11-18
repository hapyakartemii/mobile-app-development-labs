import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/domain/repositories/weather_repository.dart';

/// Static forecast until the weather REST API is connected (lab 5).
class MockWeatherRepository implements IWeatherRepository {
  const MockWeatherRepository();

  static const _forecast = WeatherForecast(
    current: CurrentConditions(
      location: 'Львів',
      temperature: 18,
      condition: WeatherCondition.partlyCloudy,
      feelsLike: 16,
      high: 21,
      low: 11,
    ),
    hourly: [
      HourlyForecast(
        time: 'Зараз',
        temperature: 18,
        condition: WeatherCondition.partlyCloudy,
      ),
      HourlyForecast(
        time: '13:00',
        temperature: 19,
        condition: WeatherCondition.sunny,
      ),
      HourlyForecast(
        time: '14:00',
        temperature: 21,
        condition: WeatherCondition.sunny,
      ),
      HourlyForecast(
        time: '15:00',
        temperature: 20,
        condition: WeatherCondition.cloudy,
      ),
      HourlyForecast(
        time: '16:00',
        temperature: 17,
        condition: WeatherCondition.rain,
      ),
      HourlyForecast(
        time: '17:00',
        temperature: 15,
        condition: WeatherCondition.rain,
      ),
    ],
  );

  @override
  Future<WeatherForecast> getForecast() async => _forecast;
}
