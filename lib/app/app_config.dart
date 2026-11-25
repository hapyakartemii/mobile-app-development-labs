import 'dart:io';

/// Connection settings for the backends.
/// Kept free of Flutter imports, so the scripts in `tool/` can use it.
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

  /// Port of `tool/server/api_server.dart`.
  static const apiPort = 8080;

  /// REST API address. The iOS simulator reaches the Mac as `localhost`,
  /// the Android emulator as `10.0.2.2`. For a real phone pass the Mac's
  /// IP: `flutter run --dart-define=API_URL=http://192.168.0.10:8080`.
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) return override;
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:$apiPort';
  }

  /// Public weather REST API, no key needed.
  static const weatherBaseUrl = 'https://api.open-meteo.com';
  static const weatherLocation = 'Львів';
  static const weatherLatitude = 49.84;
  static const weatherLongitude = 24.03;
}
