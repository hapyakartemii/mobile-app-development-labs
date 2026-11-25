import 'package:flutter_lab1/domain/entities/forecast.dart';

/// Reply of the Open-Meteo `/v1/forecast` endpoint (only the fields used).
class ForecastDto {
  const ForecastDto({
    required this.currentTime,
    required this.temperature,
    required this.feelsLike,
    required this.weatherCode,
    required this.hourlyTimes,
    required this.hourlyTemperatures,
    required this.hourlyCodes,
    required this.todayMax,
    required this.todayMin,
  });

  factory ForecastDto.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    List<T> listOf<T>(Map<String, dynamic> map, String key) =>
        (map[key] as List<dynamic>).cast<T>();

    return ForecastDto(
      currentTime: current['time'] as String,
      temperature: current['temperature_2m'] as num,
      feelsLike: current['apparent_temperature'] as num,
      weatherCode: current['weather_code'] as int,
      hourlyTimes: listOf<String>(hourly, 'time'),
      hourlyTemperatures: listOf<num>(hourly, 'temperature_2m'),
      hourlyCodes: listOf<int>(hourly, 'weather_code'),
      todayMax: listOf<num>(daily, 'temperature_2m_max').first,
      todayMin: listOf<num>(daily, 'temperature_2m_min').first,
    );
  }

  static const hoursShown = 6;

  final String currentTime;
  final num temperature;
  final num feelsLike;
  final int weatherCode;
  final List<String> hourlyTimes;
  final List<num> hourlyTemperatures;
  final List<int> hourlyCodes;
  final num todayMax;
  final num todayMin;

  WeatherForecast toEntity(String location) {
    // Hourly list starts at midnight: skip to the current hour.
    final currentHour = currentTime.substring(0, 13);
    final start = hourlyTimes
        .indexWhere((time) => time.startsWith(currentHour))
        .clamp(0, hourlyTimes.length - 1);
    final end = (start + hoursShown).clamp(0, hourlyTimes.length);

    return WeatherForecast(
      current: CurrentConditions(
        location: location,
        temperature: temperature.round(),
        condition: conditionFor(weatherCode),
        feelsLike: feelsLike.round(),
        high: todayMax.round(),
        low: todayMin.round(),
      ),
      hourly: [
        for (var i = start; i < end; i++)
          HourlyForecast(
            time: i == start ? 'Зараз' : hourlyTimes[i].substring(11, 16),
            temperature: hourlyTemperatures[i].round(),
            condition: conditionFor(hourlyCodes[i]),
          ),
      ],
    );
  }

  /// WMO weather code → app condition.
  static WeatherCondition conditionFor(int code) => switch (code) {
    0 || 1 => WeatherCondition.sunny,
    2 => WeatherCondition.partlyCloudy,
    71 || 73 || 75 || 77 || 85 || 86 => WeatherCondition.snow,
    >= 51 => WeatherCondition.rain,
    _ => WeatherCondition.cloudy,
  };
}
