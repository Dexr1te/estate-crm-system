import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/session/session_store.dart';

const _baseUrl = 'https://estate-crm-system.duckdns.org/api';

/// Marks a request that has already been replayed once after a refresh, so a
/// server that keeps answering 401 cannot drive the interceptor in a loop.
const _retriedKey = 'auth_retried';

/// Owns the [Dio] instance and the cross-cutting HTTP concerns: auth header
/// injection, transparent 401 refresh, debug logging and error parsing.
///
/// Feature data sources depend only on [dio]; they never construct Dio
/// themselves.
class ApiClient {
  final SessionStore _session;
  late final Dio dio;

  /// Refresh runs on its own [Dio], deliberately without the auth interceptor.
  /// That interceptor rewrites `Authorization` on every request it sees, so a
  /// refresh sent through [dio] would go out carrying the very access token
  /// that just expired — and its own 401 would re-enter the interceptor that
  /// issued it, refreshing forever.
  late final Dio _refreshDio;

  /// The refresh currently in flight, shared by every request that hit a 401
  /// at the same moment. The dashboard fans out three calls at once; without
  /// this each would spend the refresh token separately, and a backend that
  /// rotates refresh tokens would reject all but the first — signing the user
  /// out in the middle of a session.
  Future<void>? _refreshing;

  /// Called once when the session cannot be recovered and the tokens have been
  /// dropped. The composition root wires this to a logout: clearing storage
  /// alone leaves the router believing the user is still signed in, so every
  /// screen keeps firing requests that 401 with "Invalid email or password".
  VoidCallback? onSessionExpired;

  ApiClient(this._session, {HttpClientAdapter? adapter}) {
    dio = Dio(_options());
    _refreshDio = Dio(_options());

    // Injected by tests so both clients answer from the same fake backend.
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
      _refreshDio.httpClientAdapter = adapter;
    }

    // ── Logging (only in debug mode) ──────────────────────────
    if (kDebugMode) {
      for (final client in [dio, _refreshDio]) {
        client.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          logPrint: (o) => debugPrint('[API] $o'),
        ));
      }
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
        if (!_shouldRefresh(error)) {
          handler.next(error);
          return;
        }

        try {
          await _refreshOnce();
        } catch (_) {
          await _endSession();
          handler.next(error);
          return;
        }

        try {
          // `onRequest` re-stamps Authorization with the token we just stored.
          final opts = error.requestOptions..extra[_retriedKey] = true;
          handler.resolve(await dio.fetch(opts));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ));
  }

  static BaseOptions _options() => BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      );

  bool _shouldRefresh(DioException e) {
    if (e.response?.statusCode != 401) return false;
    // A 401 from login or invite acceptance is a credential error, not an
    // expired session; refreshing it would be meaningless.
    if (e.requestOptions.path.contains('/auth/')) return false;
    if (e.requestOptions.extra[_retriedKey] == true) return false;
    return _session.refreshToken != null;
  }

  /// Runs at most one refresh at a time; concurrent callers await the same one.
  Future<void> _refreshOnce() =>
      _refreshing ??= _performRefresh().whenComplete(() => _refreshing = null);

  Future<void> _performRefresh() async {
    final token = _session.refreshToken;
    if (token == null) throw StateError('no refresh token');
    final res = await _refreshDio.post('/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    await _session.save(AuthResponse.fromJson(res.data));
  }

  /// Drops the dead session and tells the app exactly once, even when several
  /// requests were waiting on the same failed refresh.
  Future<void> _endSession() async {
    if (_session.refreshToken == null) return; // another caller got here first
    await _session.clear();
    onSessionExpired?.call();
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
