import 'package:flutter_lab1/data/local/station_json.dart';
import 'package:flutter_lab1/data/mock/sensor_simulator.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:shelf/shelf.dart';

import 'http_helpers.dart';
import 'json_db.dart';

/// CRUD for `/stations` of the signed-in user.
class StationHandlers {
  StationHandlers(this._db);

  static const _notFound = 'Станцію не знайдено';

  final JsonDb _db;
  final SensorSimulator _simulator = SensorSimulator();

  Response list(Request request) =>
      jsonResponse(_db.stationsOf(userIdOf(request)));

  Future<Response> create(Request request) async {
    final body = await readJson(request);
    final (name, location) = (
      textField(body, 'name'),
      textField(body, 'location'),
    );
    final error = _validate(name, location);
    if (error != null) return errorResponse(400, error);

    final station = StationJson.encode(
      WeatherStation(
        id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
        name: name,
        location: location,
        isOnline: true,
        battery: 100,
        updatedAt: DateTime.now(),
        metrics: _simulator.next(),
      ),
    );
    final userId = userIdOf(request);
    await _db.saveStations(userId, [..._db.stationsOf(userId), station]);
    return jsonResponse(station, status: 201);
  }

  Future<Response> update(Request request, String id) async {
    final body = await readJson(request);
    final (name, location) = (
      textField(body, 'name'),
      textField(body, 'location'),
    );
    final error = _validate(name, location);
    if (error != null) return errorResponse(400, error);
    return _change(
      request,
      id,
      (station) => {...station, 'name': name, 'location': location},
    );
  }

  /// Values that arrived over MQTT: metrics, online state, update time.
  Future<Response> saveLive(Request request, String id) async {
    final body = await readJson(request);
    return _change(request, id, (station) {
      final updated = {
        ...station,
        'metrics': body['metrics'],
        'isOnline': body['isOnline'],
        'updatedAt': body['updatedAt'],
      };
      StationJson.decode(updated); // throws on wrong types → 400
      return updated;
    });
  }

  Future<Response> delete(Request request, String id) async {
    final userId = userIdOf(request);
    final stations = _db.stationsOf(userId);
    final remaining = [
      for (final station in stations)
        if (station['id'] != id) station,
    ];
    if (remaining.length == stations.length) {
      return errorResponse(404, _notFound);
    }
    await _db.saveStations(userId, remaining);
    return Response(204);
  }

  Future<Response> _change(
    Request request,
    String id,
    Map<String, dynamic> Function(Map<String, dynamic> station) apply,
  ) async {
    final userId = userIdOf(request);
    final stations = _db.stationsOf(userId);
    final index = stations.indexWhere((station) => station['id'] == id);
    if (index == -1) return errorResponse(404, _notFound);
    try {
      stations[index] = apply(stations[index]);
    } on TypeError {
      return errorResponse(400, 'Некоректні дані станції');
    }
    await _db.saveStations(userId, stations);
    return jsonResponse(stations[index]);
  }

  static String? _validate(String name, String location) =>
      Validators.firstError([
        Validators.stationName(name),
        Validators.location(location),
      ]);
}
