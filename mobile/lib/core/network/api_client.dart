import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/core/session/session_store.dart';

/// Where the app talks to.
///
/// Overridden at build time so a release can be pointed at a new host without a
/// code change:
/// `flutter build ipa --dart-define=API_BASE_URL=https://api.example.com/api`.
/// The default is the host 1.0 shipped against.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://estate-crm-system.onrender.com/api',
);

/// A page the backend serves for a browser rather than for the app — the
/// privacy policy and the support page.
///
/// Built onto [apiBaseUrl] and not onto its origin. The backend runs under a
/// servlet context path, so `https://host/privacy` arrives at Tomcat outside
/// that context and is answered with a 404 however healthy the service is.
/// These pages sit beside the API, under the same prefix, and the link the app
/// opens has to say so — App Store Connect wants a privacy policy URL that
/// resolves, and a reviewer taps both of these in the profile screen.
Uri backendPageUrl(String path) => Uri.parse('$apiBaseUrl$path');

const _retriedKey = 'auth_retried';
const _wokeKey = 'cold_start_retried';

/// How long one request may take while the host is waking up.
///
/// The backend sleeps when nothing has called it, and the first request after
/// that waits for a container to be built and Spring to boot — measured at well
/// over a minute, against timeouts sized for a server that is already running.
/// Stretching every timeout to match would make a genuinely dead network take
/// that long to report itself, so the short ones stay and a request that trips
/// over one is given a single second chance on this budget instead.
const _wakeUpTimeout = Duration(seconds: 90);

class ApiClient {
  final SessionStore _session;
  late final Dio dio;

  late final Dio _refreshDio;

  Future<void>? _refreshing;

  VoidCallback? onSessionExpired;

  ApiClient(this._session, {HttpClientAdapter? adapter}) {
    dio = Dio(_options());
    _refreshDio = Dio(_options());

    if (adapter != null) {
      dio.httpClientAdapter = adapter;
      _refreshDio.httpClientAdapter = adapter;
    }

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

    for (final client in [dio, _refreshDio]) {
      client.interceptors.add(_wakeUpInterceptor(client));
    }

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
          final opts = error.requestOptions..extra[_retriedKey] = true;
          handler.resolve(await dio.fetch(opts));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ));
  }

  /// Retries once, patiently, when the failure looks like a sleeping host.
  ///
  /// The retry carries [_wokeKey], so a host that is genuinely unreachable
  /// fails after one long wait rather than looping.
  Interceptor _wakeUpInterceptor(Dio client) => InterceptorsWrapper(
        onError: (error, handler) async {
          if (!_shouldWaitForWakeUp(error)) {
            handler.next(error);
            return;
          }

          try {
            final opts = error.requestOptions
              ..extra[_wokeKey] = true
              ..connectTimeout = _wakeUpTimeout
              ..receiveTimeout = _wakeUpTimeout;
            handler.resolve(await client.fetch(opts));
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      );

  static bool _shouldWaitForWakeUp(DioException e) {
    if (e.requestOptions.extra[_wokeKey] == true) return false;
    switch (e.type) {
      // Nothing was answered and nothing was sent, so nothing can happen twice.
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return true;
      // The request did reach the wire. Replaying a write could duplicate it —
      // a second POST /clients is a second client — so only a read is repeated.
      case DioExceptionType.receiveTimeout:
        return e.requestOptions.method.toUpperCase() == 'GET';
      default:
        return false;
    }
  }

  static BaseOptions _options() => BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      );

  bool _shouldRefresh(DioException e) {
    if (e.response?.statusCode != 401) return false;
    if (e.requestOptions.path.contains('/auth/')) return false;
    if (e.requestOptions.extra[_retriedKey] == true) return false;
    return _session.refreshToken != null;
  }

  Future<void> _refreshOnce() =>
      _refreshing ??= _performRefresh().whenComplete(() => _refreshing = null);

  Future<void> _performRefresh() async {
    final token = _session.refreshToken;
    if (token == null) throw StateError('no refresh token');
    final res = await _refreshDio.post('/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    await _session.save(AuthResponse.fromJson(jsonObject(res)));
  }

  Future<void> _endSession() async {
    if (_session.refreshToken == null) return;
    await _session.clear();
    onSessionExpired?.call();
  }
}
