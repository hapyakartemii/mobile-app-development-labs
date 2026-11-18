/// Connection settings for the IoT backend.
/// Kept free of Flutter imports, so `tool/sensor_publisher.dart` can use it.
abstract final class AppConfig {
  /// Public HiveMQ broker; needs no account.
  static const mqttHost = 'broker.hivemq.com';
  static const mqttPort = 1883;

  /// Unique prefix, so other users of the public broker don't interfere.
  static const mqttTopicBase = 'meteo/hapyakartemii';

  /// `#` matches every level below the base: the shared topics
  /// (`meteo/hapyakartemii/temperature`) and per-station ones
  /// (`meteo/hapyakartemii/<stationId>/temperature`).
  static const mqttTopic = '$mqttTopicBase/#';

  /// Topics of one station, shown on its screen to copy into MQTT Explorer.
  static String stationTopic(String stationId) => '$mqttTopicBase/$stationId/+';

  /// Host used to check that the internet is really reachable.
  static const connectivityProbeHost = mqttHost;
}
