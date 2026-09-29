import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/network/offline_interceptor.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/utils/money.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://estate-crm-system.onrender.com/api',
);

Uri backendPageUrl(String path) => Uri.parse('$apiBaseUrl$path');

const _retriedKey = 'auth_retried';
const _wokeKey = 'cold_start_retried';

const _wakeUpTimeout = Duration(seconds: 90);

class ApiClient {
  final SessionStore _session;
  late final Dio dio;

  late final Dio _refreshDio;

  Future<void>? _refreshing;

  VoidCallback? onSessionExpired;

  /// Reads kept for when the signal drops; null means nothing is kept.
  final OfflineCache? offlineCache;

  /// Whether what is on screen came from [offlineCache], and since when.
  final OfflineStatus offline = OfflineStatus();

  ApiClient(this._session, {HttpClientAdapter? adapter, this.offlineCache}) {
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
        options.headers['Accept-Language'] ??= AppCurrency.locale;
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

    // Last, so it only sees a failure once the cold-start retry and the token
    // refresh have both had their go.
    final cache = offlineCache;
    if (cache != null) {
      dio.interceptors.add(OfflineCacheInterceptor(
        cache: cache,
        scope: () => _session.cacheScope,
        status: offline,
      ));
      _session.addClearListener(() async {
        offline.markOnline();
        await cache.wipe();
      });
    }
  }

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
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return true;

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
