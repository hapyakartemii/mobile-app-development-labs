import 'dart:convert';
import 'dart:io';

/// Tiny database for the dev server: users and their stations, kept in a
/// JSON file so the data survives a server restart.
class JsonDb {
  JsonDb(this._file);

  final File _file;
  Map<String, dynamic> _data = {
    'users': <Object>[],
    'stations': <String, Object>{},
  };

  Future<void> load() async {
    if (_file.existsSync()) {
      _data = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    }
  }

  List<dynamic> get _users => _data['users'] as List<dynamic>;

  Map<String, dynamic> get _stations =>
      _data['stations'] as Map<String, dynamic>;

  Map<String, dynamic>? userByEmail(String email) => _users
      .cast<Map<String, dynamic>>()
      .where((user) => user['email'] == email)
      .firstOrNull;

  Map<String, dynamic>? userById(String id) => _users
      .cast<Map<String, dynamic>>()
      .where((user) => user['id'] == id)
      .firstOrNull;

  Future<void> addUser(Map<String, Object> user) async {
    _users.add(user);
    await _persist();
  }

  List<Map<String, dynamic>> stationsOf(String userId) => [
    for (final station in _stations[userId] as List<dynamic>? ?? <Object>[])
      station as Map<String, dynamic>,
  ];

  Future<void> saveStations(
    String userId,
    List<Map<String, dynamic>> stations,
  ) async {
    _stations[userId] = stations;
    await _persist();
  }

  Future<void> _persist() async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(_data),
    );
  }
}
