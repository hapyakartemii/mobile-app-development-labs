import 'dart:async';

import 'package:flutter_lab1/data/telemetry/telemetry_parser.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/domain/services/telemetry_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// [ITelemetryService] over MQTT (`mqtt_client`, TCP).
///
/// The raw MQTT stream stays inside this class; the UI only sees decoded
/// [TelemetryReading]s and [TelemetryStatus] through broadcast streams.
class MqttTelemetryService implements ITelemetryService {
  MqttTelemetryService({
    required this.host,
    required this.port,
    required this.topic,
  });

  final String host;
  final int port;

  @override
  final String topic;

  final _readings = StreamController<TelemetryReading>.broadcast();
  final _statuses = StreamController<TelemetryStatus>.broadcast();
  TelemetryStatus _status = TelemetryStatus.disconnected;
  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates;

  @override
  TelemetryStatus get status => _status;

  @override
  Stream<TelemetryStatus> get statusChanges => _statuses.stream;

  @override
  Stream<TelemetryReading> get readings => _readings.stream;

  @override
  Future<void> connect() async {
    if (_status == TelemetryStatus.connecting ||
        _status == TelemetryStatus.connected) {
      return;
    }
    _setStatus(TelemetryStatus.connecting);

    // Client id must be unique on the broker, or it drops the other client.
    final clientId = 'meteo_app_${DateTime.now().microsecondsSinceEpoch}';
    final client = MqttServerClient(host, clientId)
      ..port = port
      ..keepAlivePeriod = 20
      ..autoReconnect = true
      ..onConnected = (() => _setStatus(TelemetryStatus.connected))
      ..onAutoReconnect = (() => _setStatus(TelemetryStatus.connecting))
      ..onAutoReconnected = (() => _setStatus(TelemetryStatus.connected))
      ..onDisconnected = (() => _setStatus(TelemetryStatus.disconnected))
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);
    client.logging(on: false);
    _client = client;

    try {
      await client.connect();
    } on Exception {
      _client = null;
      client.disconnect();
      _setStatus(TelemetryStatus.failed);
      return;
    }

    client.subscribe(topic, MqttQos.atMostOnce);
    await _updates?.cancel();
    _updates = client.updates?.listen(_onMessages);
    _setStatus(TelemetryStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    await _updates?.cancel();
    _updates = null;
    final client = _client;
    _client = null;
    client?.disconnect();
    _setStatus(TelemetryStatus.disconnected);
  }

  void _onMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final publish = message.payload;
      if (publish is! MqttPublishMessage) continue;
      final payload = MqttPublishPayload.bytesToStringAsString(
        publish.payload.message,
      );
      final reading = TelemetryParser.parse(message.topic, payload);
      if (reading != null) _readings.add(reading);
    }
  }

  void _setStatus(TelemetryStatus status) {
    if (_status == status) return;
    _status = status;
    _statuses.add(status);
  }
}
