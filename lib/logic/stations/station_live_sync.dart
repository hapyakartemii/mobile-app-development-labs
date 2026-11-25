import 'dart:async';

import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/services/telemetry_service.dart';

/// Applies MQTT readings addressed to a station
/// (`meteo/hapyakartemii/<stationId>/<metric>`) to that station:
/// updates it on screen right away and saves it to the storage.
///
/// Saves run one at a time and only the newest state of each station is
/// written, so a burst of readings causes few writes and none overlap.
class StationLiveSync {
  StationLiveSync({
    required this._telemetry,
    required this._repository,
    required this.userId,
    required this.currentStations,
    required this.onStationUpdated,
  });

  final ITelemetryService _telemetry;
  final IStationRepository _repository;
  final String userId;

  /// Latest list on screen, read on every reading.
  final List<WeatherStation> Function() currentStations;

  /// Called with the updated station so the screen can show it.
  final void Function(WeatherStation station) onStationUpdated;

  final Map<String, WeatherStation> _unsaved = {};
  StreamSubscription<TelemetryReading>? _subscription;
  bool _isSaving = false;

  void start() {
    _subscription = _telemetry.readings.listen(_onReading);
  }

  void _onReading(TelemetryReading reading) {
    final station = currentStations()
        .where((station) => station.id == reading.stationId)
        .firstOrNull;
    if (station == null) return;

    final updated = station.withReading(reading);
    onStationUpdated(updated);
    _unsaved[updated.id] = updated;
    unawaited(_saveQueued());
  }

  Future<void> _saveQueued() async {
    if (_isSaving) return;
    _isSaving = true;
    try {
      while (_unsaved.isNotEmpty) {
        final station = _unsaved.remove(_unsaved.keys.first)!;
        await _repository.saveLiveData(userId, station);
      }
    } finally {
      _isSaving = false;
    }
  }

  /// Stops listening. Unsaved values are still written by the running loop.
  void dispose() {
    unawaited(_subscription?.cancel());
  }
}
