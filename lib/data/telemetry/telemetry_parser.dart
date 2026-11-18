import 'package:flutter_lab1/domain/entities/telemetry.dart';

/// Decodes MQTT messages like `meteo/hapyakartemii/temperature` → `21.5`.
abstract final class TelemetryParser {
  static const _metrics = {
    'temperature': SensorMetric.temperature,
    'humidity': SensorMetric.humidity,
    'pressure': SensorMetric.pressure,
    'wind': SensorMetric.wind,
  };

  /// The metric comes from the last topic level, the value from the
  /// payload. Returns `null` for unknown topics or non-numeric payloads,
  /// so a bad message is skipped instead of crashing the app.
  static TelemetryReading? parse(
    String topic,
    String payload, {
    DateTime? now,
  }) {
    final metric = _metrics[topic.split('/').last];
    final value = double.tryParse(payload.trim().replaceAll(',', '.'));
    if (metric == null || value == null) return null;
    return TelemetryReading(
      metric: metric,
      value: value,
      receivedAt: now ?? DateTime.now(),
    );
  }
}
