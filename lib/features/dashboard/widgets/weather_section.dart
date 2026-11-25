import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/features/dashboard/widgets/current_weather_card.dart';
import 'package:flutter_lab1/features/dashboard/widgets/hourly_forecast_strip.dart';
import 'package:flutter_lab1/features/shared/widgets/error_view.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';

/// Forecast from the Open-Meteo REST API, shown with a [FutureBuilder]:
/// loading → spinner, success → card and hourly strip, error → notice.
///
/// The request starts once in [State.initState], not in `build`, so
/// rebuilds don't send it again. A new `key` from the parent reloads it.
class WeatherSection extends StatefulWidget {
  const WeatherSection({super.key});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> {
  late final Future<WeatherForecast> _forecast = AppScope.of(
    context,
  ).weatherRepository.getForecast();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherForecast>(
      future: _forecast,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final forecast = snapshot.data;
        if (snapshot.hasError || forecast == null) {
          return NoticeBanner(
            icon: Icons.cloud_off_outlined,
            message: ErrorView.messageOf(snapshot.error),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CurrentWeatherCard(conditions: forecast.current),
            const SectionHeader(title: 'Прогноз на найближчі години'),
            HourlyForecastStrip(items: forecast.hourly),
          ],
        );
      },
    );
  }
}
