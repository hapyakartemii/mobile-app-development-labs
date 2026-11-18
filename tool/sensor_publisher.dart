import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_lab1/app/app_config.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Pretends to be a weather station: publishes readings to the same
/// broker and topics the app listens to.
///
/// Run from the project root:
///   dart run tool/sensor_publisher.dart              → shared topics
///   dart run tool/sensor_publisher.dart STATION_ID   → one station
/// (the station id is shown on the station screen in the app).
/// Stop with Ctrl+C.
Future<void> main(List<String> args) async {
  final stationId = args.firstOrNull;
  final topicBase = stationId == null
      ? AppConfig.mqttTopicBase
      : '${AppConfig.mqttTopicBase}/$stationId';
  final random = Random();
  final clientId = 'meteo_publisher_${random.nextInt(1 << 30)}';
  final client = MqttServerClient(AppConfig.mqttHost, clientId)
    ..port = AppConfig.mqttPort
    ..keepAlivePeriod = 20
    ..connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
  client.logging(on: false);

  stdout.writeln('Connecting to ${AppConfig.mqttHost}:${AppConfig.mqttPort}…');
  await client.connect();
  stdout.writeln('Publishing to $topicBase/<metric> every 3 s');

  // Random walk, so values change smoothly like real sensors.
  var temperature = 18.0;
  var humidity = 60.0;
  var pressure = 1012.0;
  var wind = 3.0;
  double drift(double value, double step, double min, double max) =>
      (value + (random.nextDouble() - 0.5) * step).clamp(min, max);

  final timer = Timer.periodic(const Duration(seconds: 3), (_) {
    temperature = drift(temperature, 1, -20, 40);
    humidity = drift(humidity, 4, 10, 100);
    pressure = drift(pressure, 2, 960, 1050);
    wind = drift(wind, 1.5, 0, 25);

    _publish(client, topicBase, 'temperature', temperature.toStringAsFixed(1));
    _publish(client, topicBase, 'humidity', humidity.toStringAsFixed(0));
    _publish(client, topicBase, 'pressure', pressure.toStringAsFixed(0));
    _publish(client, topicBase, 'wind', wind.toStringAsFixed(1));
    stdout.writeln();
  });

  await ProcessSignal.sigint.watch().first;
  timer.cancel();
  client.disconnect();
  stdout.writeln('Stopped.');
  exit(0);
}

void _publish(
  MqttServerClient client,
  String topicBase,
  String metric,
  String value,
) {
  final payload = MqttClientPayloadBuilder()..addString(value);
  client.publishMessage(
    '$topicBase/$metric',
    MqttQos.atMostOnce,
    payload.payload!,
  );
  stdout.writeln('→ $topicBase/$metric = $value');
}
