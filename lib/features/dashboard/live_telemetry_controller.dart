import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';
import 'package:flutter_lab1/domain/services/telemetry_service.dart';

/// Holds the latest MQTT values: of one station ([stationId]) or, if it is
/// `null`, of every station (the dashboard shows when the last one came).
///
/// Keeps stream handling out of widgets: subscribes to the telemetry and
/// connectivity streams in [start], and cancels every subscription and
/// disconnects in [dispose], so nothing leaks after the screen closes.
class LiveTelemetryController extends ChangeNotifier {
  LiveTelemetryController({
    required ITelemetryService telemetry,
    required this._connectivity,
    this.stationId,
    this.managesConnection = true,
  }) : _telemetry = telemetry,
       _status = telemetry.status;

  /// Station whose readings to keep; `null` keeps all of them.
  final String? stationId;

  /// Whether this controller opens and closes the broker connection.
  /// The dashboard does; the station screen, opened on top of it, only
  /// listens to the already open connection.
  final bool managesConnection;

  final ITelemetryService _telemetry;
  final IConnectivityService _connectivity;
  final Map<SensorMetric, TelemetryReading> _latest = {};
  TelemetryStatus _status;
  DateTime? _lastMessageAt;
  StreamSubscription<TelemetryReading>? _readingsSubscription;
  StreamSubscription<TelemetryStatus>? _statusSubscription;
  StreamSubscription<bool>? _networkSubscription;
  bool _isDisposed = false;

  TelemetryStatus get status => _status;

  String get topic => _telemetry.topic;

  /// When the last message arrived, or `null` if none yet.
  DateTime? get lastMessageAt => _lastMessageAt;

  /// Latest value of [metric], or `null` if nothing arrived yet.
  TelemetryReading? latest(SensorMetric metric) => _latest[metric];

  Future<void> start() async {
    _readingsSubscription = _telemetry.readings.listen(_onReading);
    _statusSubscription = _telemetry.statusChanges.listen(_onStatus);
    if (!managesConnection) return;
    // Reconnect as soon as the internet comes back.
    _networkSubscription = _connectivity.onlineChanges.listen((isOnline) {
      if (isOnline) unawaited(_telemetry.connect());
    });

    final isOnline = await _connectivity.isOnline();
    if (_isDisposed) return;
    if (isOnline) {
      await _telemetry.connect();
    } else {
      _onStatus(TelemetryStatus.disconnected);
    }
  }

  void _onReading(TelemetryReading reading) {
    if (stationId != null && reading.stationId != stationId) return;
    _latest[reading.metric] = reading;
    _lastMessageAt = reading.receivedAt;
    notifyListeners();
  }

  void _onStatus(TelemetryStatus status) {
    if (_isDisposed) return;
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_readingsSubscription?.cancel());
    unawaited(_statusSubscription?.cancel());
    unawaited(_networkSubscription?.cancel());
    if (managesConnection) unawaited(_telemetry.disconnect());
    super.dispose();
  }
}
