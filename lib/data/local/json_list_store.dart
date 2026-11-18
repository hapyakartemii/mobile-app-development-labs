import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores a list of JSON objects under one SharedPreferences key.
class JsonListStore {
  const JsonListStore(this._prefs, {this.latency = Duration.zero});

  final SharedPreferences _prefs;

  /// Artificial delay that imitates a network call, so loading indicators
  /// are visible and the UI is ready for the REST API in lab 5.
  final Duration latency;

  Future<List<Map<String, dynamic>>> read(String key) async {
    await _delay();
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> write(String key, List<Map<String, Object>> items) async {
    await _prefs.setString(key, jsonEncode(items));
  }

  Future<void> _delay() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);
}
