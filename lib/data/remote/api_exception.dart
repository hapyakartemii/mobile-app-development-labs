import 'package:dio/dio.dart';

/// Failed HTTP call, translated into a message the user can understand.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  /// Maps any [DioException] (no connection, timeout, non-2xx status).
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response == null) {
      return ApiException(switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'Сервер не відповідає. Спробуйте пізніше.',
        _ => 'Немає зʼєднання з сервером.',
      }, isNetworkError: true);
    }

    final status = response.statusCode ?? 0;
    final data = response.data;
    final serverMessage = data is Map && data['error'] is String
        ? data['error'] as String
        : null;
    return ApiException(
      serverMessage ?? messageForStatus(status),
      statusCode: status,
    );
  }

  final String message;

  /// HTTP status, or `null` if the server wasn't reached at all.
  final int? statusCode;

  /// No connection or timeout: cached data can be shown instead.
  final bool isNetworkError;

  /// Session token missing, forged or expired.
  bool get isUnauthorized => statusCode == 401;

  static String messageForStatus(int status) => switch (status) {
    400 => 'Некоректний запит.',
    401 => 'Сесія закінчилась. Увійдіть знову.',
    403 => 'Доступ заборонено.',
    404 => 'Не знайдено.',
    409 => 'Конфлікт даних.',
    >= 500 => 'Помилка сервера. Спробуйте пізніше.',
    _ => 'Неочікувана відповідь сервера ($status).',
  };

  @override
  String toString() => 'ApiException($statusCode): $message';
}
