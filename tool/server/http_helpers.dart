import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'jwt.dart';

/// JSON response with the right content type.
Response jsonResponse(Object body, {int status = 200}) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Error in the format the app expects: `{"error": "message"}`.
Response errorResponse(int status, String message) =>
    jsonResponse({'error': message}, status: status);

/// Request body as a JSON object; throws [FormatException] otherwise.
Future<Map<String, dynamic>> readJson(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return {};
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Очікувався JSON-обʼєкт');
  }
  return decoded;
}

/// Text field from a JSON body, trimmed; empty if missing.
String textField(Map<String, dynamic> body, String key) =>
    (body[key] is String ? body[key] as String : '').trim();

/// Id of the user the request was authorised for (set by [requireAuth]).
String userIdOf(Request request) => request.context['userId']! as String;

/// Every route except `/auth/*` needs `Authorization: Bearer <jwt>`.
/// A missing, forged or expired token gets 401.
Middleware requireAuth(Jwt jwt) =>
    (inner) => (request) {
      if (request.url.path.startsWith('auth/')) return inner(request);
      final header = request.headers['authorization'] ?? '';
      final userId = header.startsWith('Bearer ')
          ? jwt.verify(header.substring('Bearer '.length))
          : null;
      if (userId == null) return errorResponse(401, 'Потрібна авторизація');
      return inner(request.change(context: {'userId': userId}));
    };

/// Turns malformed JSON into 400 instead of crashing the request.
Middleware handleBadJson() =>
    (inner) => (request) async {
      try {
        return await inner(request);
      } on FormatException catch (error) {
        return errorResponse(400, 'Некоректний JSON: ${error.message}');
      }
    };
