import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/session/session_store.dart';

const _baseUrl = 'http://20.213.138.132/api';

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
    } else {
      debugPrint('[API ERROR] unknown: $e');
    }
    return apiErrorMessage(e);
  }
}
