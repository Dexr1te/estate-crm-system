import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';

/// Set on a response that came from the offline cache, holding the
/// [DateTime] the server originally gave that answer.
const offlineCachedAtKey = 'offline_cached_at';

const _keyExtra = 'offline_cache_key';

/// Whether the app is showing answers from the offline cache, and since when.
///
/// The value is the time the oldest cached answer on show was fresh, or null
/// once the server has answered anything again.
class OfflineStatus extends ValueNotifier<DateTime?> {
  OfflineStatus() : super(null);

  bool get isStale => value != null;

  void markStale(DateTime savedAt) {
    final current = value;
    if (current == null || savedAt.isBefore(current)) value = savedAt;
  }

  void markOnline() => value = null;
}

/// True when [e] means the server could not be reached, rather than that it
/// answered no. A 502/503/504 counts as unreachable: on this host it is the
/// proxy saying the app is asleep or restarting, not the app refusing.
bool isConnectivityFailure(DioException e) {
  final status = e.response?.statusCode;
  if (status != null) return status == 502 || status == 503 || status == 504;
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return true;
    default:
      return false;
  }
}

/// Network first; the cache only speaks when the network cannot.
///
/// A successful read of a main entity is written to [cache] under the
/// current [scope]. When a read fails for lack of a connection, the last
/// answer kept for that same request and scope is served instead, marked with
/// [offlineCachedAtKey], and [status] turns stale. A server that answers with
/// an error — 401, 404, 500 — is never masked. With no scope (nobody signed
/// in) nothing is read or written.
class OfflineCacheInterceptor extends Interceptor {
  OfflineCacheInterceptor({
    required this.cache,
    required this.scope,
    required this.status,
  });

  final OfflineCache cache;
  final String? Function() scope;
  final OfflineStatus status;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final who = scope();
    if (who != null && OfflineCache.isCacheable(options.method, options.path)) {
      options.extra[_keyExtra] = OfflineCache.keyFor(
        method: options.method,
        path: options.path,
        query: options.queryParameters,
        scope: who,
      );
    } else {
      options.extra.remove(_keyExtra);
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    status.markOnline();
    final key = response.requestOptions.extra[_keyExtra];
    final code = response.statusCode ?? 0;
    if (key is String && code >= 200 && code < 300) {
      await cache.write(key, response.data, statusCode: code);
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (!isConnectivityFailure(err)) {
      if (err.response != null) status.markOnline();
      handler.next(err);
      return;
    }

    final key = err.requestOptions.extra[_keyExtra];
    final cached = key is String ? await cache.read(key) : null;
    if (cached == null) {
      handler.next(err);
      return;
    }

    status.markStale(cached.savedAt);
    handler.resolve(Response<dynamic>(
      requestOptions: err.requestOptions,
      data: cached.data,
      statusCode: cached.statusCode,
      extra: {offlineCachedAtKey: cached.savedAt},
    ));
  }
}
