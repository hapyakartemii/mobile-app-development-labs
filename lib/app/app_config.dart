/// Connection settings for the IoT backend.
/// Kept free of Flutter imports, so `tool/sensor_publisher.dart` can use it.
abstract final class AppConfig {
  /// Public HiveMQ broker; needs no account.
  static const mqttHost = 'broker.hivemq.com';
  static const mqttPort = 1883;

  /// Unique prefix, so other users of the public broker don't interfere.
  static const mqttTopicBase = 'meteo/hapyakartemii';

  /// `+` matches one level: temperature, humidity, pressure, wind.
  static const mqttTopic = '$mqttTopicBase/+';

  /// Host used to check that the internet is really reachable.
  static const connectivityProbeHost = mqttHost;
}
