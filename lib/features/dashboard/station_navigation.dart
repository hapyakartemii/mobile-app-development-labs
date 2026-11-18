import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/shared/widgets/confirm_dialog.dart';

/// Opens the station form: empty for a new station, filled for [station].
/// Returns the entered data, or `null` if the user went back.
Future<StationDraft?> openStationForm(
  BuildContext context, [
  WeatherStation? station,
]) async {
  final result = await Navigator.pushNamed(
    context,
    AppRoutes.stationForm,
    arguments: station,
  );
  return result is StationDraft ? result : null;
}

/// Opens the screen with a station's details and live MQTT values.
void openStationDetails(BuildContext context, WeatherStation station) {
  Navigator.pushNamed(context, AppRoutes.stationDetails, arguments: station);
}

/// Asks whether to delete [station]; `true` only if the user confirms.
Future<bool> confirmStationDeletion(
  BuildContext context,
  WeatherStation station,
) {
  return showConfirmDialog(
    context,
    title: 'Видалити станцію?',
    message: '«${station.name}» буде видалено разом з її даними.',
    confirmLabel: 'Видалити',
  );
}
