/// Values a station streams over MQTT, one topic each.
enum SensorMetric { temperature, humidity, pressure, wind }

/// State of the connection to the MQTT broker.
enum TelemetryStatus { disconnected, connecting, connected, failed }

/// One value received from the broker.
class TelemetryReading {
  const TelemetryReading({
    required this.metric,
    required this.value,
    required this.receivedAt,
  });

  final SensorMetric metric;
  final double value;
  final DateTime receivedAt;
}
