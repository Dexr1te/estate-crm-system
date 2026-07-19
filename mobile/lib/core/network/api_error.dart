import 'package:dio/dio.dart';

/// Converts any thrown error — usually a [DioException] — into a concise,
/// user-facing message.
///
/// Priority:
///   1. Backend field-level validation errors (`validationErrors` map)
///   2. The backend's own `message` / `error` body field
///      (e.g. "Email already registered: john@x.com")
///   3. A sensible fallback based on HTTP status or connection failure type
///
/// This is the single source of truth for turning API failures into text, so
/// blocs never surface raw `DioException.toString()` boilerplate to the user.
String apiErrorMessage(Object? error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final ve = data['validationErrors'];
      if (ve is Map && ve.isNotEmpty) {
        return ve.values.map((v) => v.toString()).join('\n');
      }
      final msg = data['message'] ?? data['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    }

    final status = error.response?.statusCode;
    if (status == 401) return 'Invalid email or password.';
    if (status == 403) return 'You don’t have permission to do that.';
    if (status == 404) return 'Not found.';
    if (status == 409) return 'This already exists.';
    if (status == 400) return 'Invalid request. Please check your input.';
    if (status != null && status >= 500) {
      return 'Server error. Please try again later.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your internet.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Check your internet.';
      default:
        break;
    }
  }
  return 'Something went wrong. Please try again.';
}
