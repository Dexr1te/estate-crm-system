import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _expiredAccess = 'EXPIRED_ACCESS';
const _refresh = 'GOOD_REFRESH';

Response<dynamic> _swallow(Object _) =>
    Response(requestOptions: RequestOptions(path: '/'));

class _Backend implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  bool rejectRefresh = false;

  bool alwaysReject = false;

  int get refreshCalls =>
      requests.where((r) => r.path.contains('/auth/refresh')).length;

  List<String?> get refreshAuth => requests
      .where((r) => r.path.contains('/auth/refresh'))
      .map((r) => r.headers['Authorization'] as String?)
      .toList();

  static const _maxRefreshes = 5;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);

    if (options.path.contains('/auth/refresh')) {
      if (refreshCalls > _maxRefreshes) {
        return _json({'error': 'runaway'}, 500);
      }
      final auth = options.headers['Authorization'];
      if (rejectRefresh || auth != 'Bearer $_refresh') {
        return _json({'error': 'bad token'}, 401);
      }
      return _json({
        'accessToken': 'NEW_ACCESS',
        'refreshToken': 'NEW_REFRESH',
        'tokenType': 'Bearer',
        'userId': 1,
        'fullName': 'A',
        'email': 'a@b.c',
        'role': 'AGENT',
      }, 200);
    }

    final auth = options.headers['Authorization'];
    if (!alwaysReject && auth == 'Bearer NEW_ACCESS') {
      return _json({'ok': true}, 200);
    }
    return _json({'error': 'expired'}, 401);
  }

  ResponseBody _json(Map<String, dynamic> body, int status) =>
      ResponseBody.fromString(jsonEncode(body), status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });

  @override
  void close({bool force = false}) {}
}

Future<(ApiClient, _Backend, SessionStore)> _build() async {
  SharedPreferences.setMockInitialValues({
    'access_token': _expiredAccess,
    'refresh_token': _refresh,
  });
  final session = SessionStore();
  await session.load();
  final backend = _Backend();
  return (ApiClient(session, adapter: backend), backend, session);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the refresh call carries the refresh token, not the stale access token',
      () async {
    final (client, backend, _) = await _build();

    final res = await client.dio.get('/clients');

    expect(backend.refreshAuth, isNotEmpty, reason: 'refresh should be tried');
    expect(backend.refreshAuth.single, 'Bearer $_refresh',
        reason: 'the auth interceptor must not overwrite the Authorization '
            'header the refresh call set deliberately');
    expect(res.statusCode, 200,
        reason: 'the original request should be replayed with the new token');
  });

  test('one expired token triggers exactly one refresh', () async {
    final (client, backend, _) = await _build();

    await client.dio.get('/clients');

    expect(backend.refreshCalls, 1,
        reason: 'the refresh must not retry itself in a loop');
  });

  test('parallel requests share a single refresh', () async {
    final (client, backend, _) = await _build();

    await Future.wait([
      client.dio.get('/dashboard'),
      client.dio.get('/meetings'),
      client.dio.get('/deals'),
    ]);

    expect(backend.refreshCalls, 1,
        reason: 'three concurrent 401s must not spend the refresh token three '
            'times — a backend that rotates it would reject two of them');
  });

  test('a dead refresh token ends the session exactly once', () async {
    final (client, backend, session) = await _build();
    backend.rejectRefresh = true;
    var expiredSignals = 0;
    client.onSessionExpired = () => expiredSignals++;

    await Future.wait([
      client.dio.get('/dashboard').catchError(_swallow),
      client.dio.get('/meetings').catchError(_swallow),
    ]);

    expect(session.refreshToken, isNull, reason: 'the tokens must be dropped');
    expect(expiredSignals, 1,
        reason: 'the app has to be told, or the router keeps believing the '
            'user is signed in and every screen 401s forever');
  });

  test('a request that still 401s after a good refresh is not retried again',
      () async {
    final (client, backend, _) = await _build();
    backend.alwaysReject = true;

    await client.dio.get('/clients').catchError(_swallow);

    expect(backend.refreshCalls, 1);
    expect(backend.requests.where((r) => r.path == '/clients'), hasLength(2),
        reason: 'the original attempt plus exactly one replay');
  });

  test('a 401 from login is not treated as an expired session', () async {
    final (client, backend, _) = await _build();

    await client.dio.post('/auth/login',
        data: {'email': 'a@b.c', 'password': 'wrong'}).catchError(_swallow);

    expect(backend.refreshCalls, 0,
        reason: 'bad credentials are not a stale token');
  });
}
