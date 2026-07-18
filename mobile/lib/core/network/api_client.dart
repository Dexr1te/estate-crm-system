import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/session/session_store.dart';

const _baseUrl = 'https://estate-crm-system.onrender.com/api';

/// Owns the [Dio] instance and the cross-cutting HTTP concerns: auth header
/// injection, transparent 401 refresh, debug logging and error parsing.
///
/// Feature data sources depend only on [dio]; they never construct Dio
/// themselves.
class ApiClient {
  final SessionStore _session;
  late final Dio dio;

  ApiClient(this._session) {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    // ── Logging (only in debug mode) ──────────────────────────
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (o) => debugPrint('[API] $o'),
      ));
    }

    // ── Auth + refresh interceptor ────────────────────────────
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _session.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            _session.refreshToken != null) {
          try {
            final newAuth = await _doRefresh(_session.refreshToken!);
            await _session.save(newAuth);
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${_session.accessToken}';
            final response = await dio.fetch(opts);
            handler.resolve(response);
            return;
          } catch (_) {
            await _session.clear();
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<AuthResponse> _doRefresh(String token) async {
    final res = await dio.post('/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return AuthResponse.fromJson(res.data);
  }

  // ──────────────────────────────────────────
  // Error parser
  // ──────────────────────────────────────────

  String parseError(dynamic e) {
    if (e is DioException) {
      debugPrint(
          '[API ERROR] type: ${e.type} | status: ${e.response?.statusCode} | data: ${e.response?.data}');
      final status = e.response?.statusCode;

      // Try to get message from backend response body
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'];
        if (msg != null && msg.toString().isNotEmpty) {
          return msg.toString();
        }
      }

      if (status == 400) return 'Invalid request. Check your input.';
      if (status == 401) return 'Invalid email or password.';
      if (status == 403) return 'Access denied.';
      if (status == 404) return 'Not found.';
      if (status == 409) return 'Email already registered.';
      if (status != null && status >= 500) {
        return 'Server error. Try again later.';
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Check your internet.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Cannot connect to server. Check your internet.';
      }
    }
    debugPrint('[API ERROR] unknown: $e');
    return 'Something went wrong. Please try again.';
  }
}
