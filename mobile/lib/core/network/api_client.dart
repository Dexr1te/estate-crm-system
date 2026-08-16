import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/session/session_store.dart';

/// Where the app talks to.
///
/// Overridden at build time so a release can be pointed at a new host without a
/// code change:
/// `flutter build ipa --dart-define=API_BASE_URL=https://api.example.com/api`.
/// The default is the host 1.0 shipped against.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://estate-crm-system.duckdns.org/api',
);

/// The origin behind [apiBaseUrl], for pages served by the backend rather than
/// its API — the privacy policy and the support page.
final apiOrigin = Uri.parse(apiBaseUrl).origin;

const _retriedKey = 'auth_retried';

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
    await _session.save(AuthResponse.fromJson(res.data));
  }

  Future<void> _endSession() async {
    if (_session.refreshToken == null) return;
    await _session.clear();
    onSessionExpired?.call();
  }
}
