import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/app/theme/responsive.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/widgets/dashboard_overview.dart';
import 'package:flutter_lab1/features/dashboard/widgets/station_list.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';

/// Dashboard layout: one column on phones, two columns on wide screens.
/// Holds no state; [MainScreen] passes data and callbacks in.
class DashboardView extends StatelessWidget {
  const DashboardView({
    required this.forecast,
    required this.stations,
    required this.onAdd,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Room so the floating button doesn't cover the last card.
  static const double _fabClearance = 80;

  final WeatherForecast forecast;
  final List<WeatherStation> stations;
  final VoidCallback onAdd;
  final ValueChanged<WeatherStation> onOpen;
  final ValueChanged<WeatherStation> onEdit;
  final ValueChanged<WeatherStation> onDelete;

  @override
  Widget build(BuildContext context) {
    final overview = DashboardOverview(
      forecast: forecast,
      mainStation: stations.firstOrNull,
    );
    final stationList = StationList(
      stations: stations,
      onAdd: onAdd,
      onOpen: onOpen,
      onEdit: onEdit,
      onDelete: onDelete,
    );

    return PageBody(
      child: Padding(
        padding: const EdgeInsets.only(bottom: _fabClearance),
        child: context.isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.l,
                children: [
                  Expanded(flex: 3, child: overview),
                  Expanded(flex: 2, child: stationList),
                ],
              )
            : Column(children: [overview, stationList]),
      ),
    );
  }
}
