import 'package:flutter_lab1/domain/entities/telemetry.dart';

/// Live sensor data from IoT devices (MQTT now, could be WebSocket later).
abstract interface class ITelemetryService {
  /// Topic filter the service listens to, shown in the UI.
  String get topic;

  TelemetryStatus get status;

  /// Emits every change of [status].
  Stream<TelemetryStatus> get statusChanges;

  /// Emits each decoded value as it arrives.
  Stream<TelemetryReading> get readings;

  /// Connects and subscribes. Does nothing if already connected.
  Future<void> connect();

  /// Unsubscribes and closes the connection.
  Future<void> disconnect();
}
