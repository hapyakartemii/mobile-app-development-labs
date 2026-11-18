enum WeatherCondition { sunny, partlyCloudy, cloudy, rain }

/// Current conditions shown at the top of the dashboard.
class CurrentConditions {
  const CurrentConditions({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.feelsLike,
    required this.high,
    required this.low,
  });

  final String location;
  final int temperature;
  final WeatherCondition condition;
  final int feelsLike;
  final int high;
  final int low;
}

/// Forecast for a single hour.
class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });

  final String time;
  final int temperature;
  final WeatherCondition condition;
}

class WeatherForecast {
  const WeatherForecast({required this.current, required this.hourly});

  final CurrentConditions current;
  final List<HourlyForecast> hourly;
}
