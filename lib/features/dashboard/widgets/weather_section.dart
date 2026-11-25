import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/features/dashboard/widgets/current_weather_card.dart';
import 'package:flutter_lab1/features/dashboard/widgets/hourly_forecast_strip.dart';
import 'package:flutter_lab1/features/shared/widgets/notice_banner.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';
import 'package:flutter_lab1/logic/weather/weather_cubit.dart';
import 'package:flutter_lab1/logic/weather/weather_state.dart';

/// Forecast drawn from [WeatherState]: spinner, data or an inline notice.
class WeatherSection extends StatelessWidget {
  const WeatherSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) => switch (state) {
        WeatherState(status: WeatherStatus.loaded, :final forecast?) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CurrentWeatherCard(conditions: forecast.current),
            const SectionHeader(title: 'Прогноз на найближчі години'),
            HourlyForecastStrip(items: forecast.hourly),
          ],
        ),
        WeatherState(status: WeatherStatus.failure, :final error) =>
          NoticeBanner(
            icon: Icons.cloud_off_outlined,
            message: error ?? 'Прогноз недоступний.',
          ),
        _ => const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }
}
