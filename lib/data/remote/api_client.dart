import 'package:dio/dio.dart';
import 'package:flutter_lab1/data/remote/api_exception.dart';
import 'package:flutter_lab1/domain/repositories/session_storage.dart';

/// HTTP client built on `dio`: base URL, timeouts, JSON, and the JWT added
/// to every request by an interceptor.
///
/// Every call goes through [_send], so any failure — no network, timeout,
/// or a status outside 2xx — becomes an [ApiException] instead of a crash.
class ApiClient {
  ApiClient({required String baseUrl, ISessionStorage? sessions, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
              contentType: Headers.jsonContentType,
            ),
          ) {
    if (sessions != null) _dio.interceptors.add(_AuthInterceptor(sessions));
  }

  final Dio _dio;

  /// Body as a JSON object, or an [ApiException] if the server sent
  /// something else — a broken reply must not crash the app.
  static Map<String, dynamic> objectOf(Object? data) {
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Некоректна відповідь сервера.');
  }

  /// Body as a list of JSON objects (see [objectOf]).
  static List<Map<String, dynamic>> listOf(Object? data) {
    if (data is List<dynamic>) return [for (final item in data) objectOf(item)];
    throw const ApiException('Некоректна відповідь сервера.');
  }

  Future<Object?> get(String path, {Map<String, Object>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query));

  Future<Object?> post(String path, Object body) =>
      _send(() => _dio.post<Object?>(path, data: body));

  Future<Object?> put(String path, Object body) =>
      _send(() => _dio.put<Object?>(path, data: body));

  Future<Object?> patch(String path, Object body) =>
      _send(() => _dio.patch<Object?>(path, data: body));

  Future<Object?> delete(String path) =>
      _send(() => _dio.delete<Object?>(path));

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

/// Adds `Authorization: Bearer <token>` when a session is saved.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._sessions);

  final ISessionStorage _sessions;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = await _sessions.read();
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.token}';
    }
    handler.next(options);
  }
}
