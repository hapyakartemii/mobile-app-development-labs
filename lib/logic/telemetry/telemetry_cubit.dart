import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';
import 'package:flutter_lab1/domain/services/telemetry_service.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_state.dart';

/// Owns the MQTT connection while the user is signed in: connects in
/// [start], reconnects when the internet returns, disconnects in [stop].
/// Every stream subscription is cancelled in [stop] / [close].
class TelemetryCubit extends Cubit<TelemetryState> {
  TelemetryCubit(this._telemetry, this._connectivity)
    : super(TelemetryState(status: _telemetry.status));

  final ITelemetryService _telemetry;
  final IConnectivityService _connectivity;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  String get topic => _telemetry.topic;

  Future<void> start() async {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions
      ..add(_telemetry.statusChanges.listen(_onStatus))
      ..add(
        _telemetry.readings.listen(
          (reading) =>
              _update(state.copyWith(lastMessageAt: reading.receivedAt)),
        ),
      )
      ..add(
        _connectivity.onlineChanges.listen((isOnline) {
          if (isOnline) unawaited(_telemetry.connect());
        }),
      );
    if (await _connectivity.isOnline()) {
      await _telemetry.connect();
    } else {
      _onStatus(TelemetryStatus.disconnected);
    }
  }

  Future<void> stop() async {
    final subscriptions = [..._subscriptions];
    _subscriptions.clear();
    await _telemetry.disconnect();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    _update(const TelemetryState());
  }

  void _onStatus(TelemetryStatus status) =>
      _update(state.copyWith(status: status));

  void _update(TelemetryState next) {
    if (!isClosed) emit(next);
  }

  @override
  Future<void> close() async {
    await stop();
    return super.close();
  }
}
