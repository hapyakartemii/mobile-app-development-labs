import 'package:flutter_lab1/domain/entities/telemetry.dart';

/// Decodes MQTT messages:
/// * `meteo/hapyakartemii/temperature` → `21.5` (shared, no station);
/// * `meteo/hapyakartemii/<stationId>/temperature` → `21.5` (one station).
abstract final class TelemetryParser {
  static const _metrics = {
    'temperature': SensorMetric.temperature,
    'humidity': SensorMetric.humidity,
    'pressure': SensorMetric.pressure,
    'wind': SensorMetric.wind,
  };

  /// The metric comes from the last topic level, the station id from the
  /// level before it (if the topic has one), the value from the payload.
  /// Returns `null` for unknown topics or non-numeric payloads, so a bad
  /// message is skipped instead of crashing the app.
  static TelemetryReading? parse(
    String topic,
    String payload, {
    DateTime? now,
  }) {
    final levels = topic.split('/');
    final metric = _metrics[levels.last];
    final value = double.tryParse(payload.trim().replaceAll(',', '.'));
    if (metric == null || value == null) return null;
    return TelemetryReading(
      metric: metric,
      value: value,
      receivedAt: now ?? DateTime.now(),
      // base (2 levels) + station + metric = 4 levels.
      stationId: levels.length >= 4 ? levels[levels.length - 2] : null,
    );
  }
}
