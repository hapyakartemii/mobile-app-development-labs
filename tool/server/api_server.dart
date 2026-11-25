import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'auth_handlers.dart';
import 'http_helpers.dart';
import 'json_db.dart';
import 'jwt.dart';
import 'station_handlers.dart';

/// REST API of the weather station app (development server).
///
/// Run from the project root:   dart run tool/server/api_server.dart
/// Stop with Ctrl+C. Data is kept in tool/server/data/db.json.
///
///   POST   /auth/register      → 201 {token, user}
///   POST   /auth/login         → 200 {token, user}
///   GET    /me                 → 200 user              (JWT required)
///   GET    /stations           → 200 [station]         (JWT required)
///   POST   /stations           → 201 station           (JWT required)
///   PUT    /stations/{id}      → 200 station           (JWT required)
///   PATCH  /stations/{id}/live → 200 station           (JWT required)
///   DELETE /stations/{id}      → 204                   (JWT required)
Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final secret = Platform.environment['JWT_SECRET'] ?? 'dev-only-secret';

  final db = JsonDb(File('tool/server/data/db.json'));
  await db.load();
  final jwt = Jwt(secret);
  final auth = AuthHandlers(db, jwt);
  final stations = StationHandlers(db);

  final router = Router()
    ..post('/auth/register', auth.register)
    ..post('/auth/login', auth.login)
    ..get('/me', auth.me)
    ..get('/stations', stations.list)
    ..post('/stations', stations.create)
    ..put('/stations/<id>', stations.update)
    ..patch('/stations/<id>/live', stations.saveLive)
    ..delete('/stations/<id>', stations.delete);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleBadJson())
      .addMiddleware(requireAuth(jwt))
      .addHandler(router.call);

  // anyIPv4: reachable as localhost (iOS simulator) and 10.0.2.2 (Android).
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('API is running on http://localhost:${server.port}');
}
