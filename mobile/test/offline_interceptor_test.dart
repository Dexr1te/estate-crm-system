import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/network/offline_interceptor.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A host the test can unplug, or make answer with an error status.
class _Host implements HttpClientAdapter {
  bool online = true;
  int status = 200;
  Object body = [
    {'id': 1, 'fullName': 'Aisha'}
  ];

  /// How many calls to fail with [failure] before answering — a cold start.
  int sleepyCalls = 0;
  DioExceptionType failure = DioExceptionType.connectionError;

  final List<RequestOptions> calls = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    calls.add(options);
    if (!online || sleepyCalls > 0) {
      if (sleepyCalls > 0) sleepyCalls--;
      throw DioException(requestOptions: options, type: failure);
    }
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late _Host host;
  late SessionStore session;
  late ApiClient client;
  final t0 = DateTime(2026, 9, 26, 14, 32);

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('offline_interceptor_test');
    AppClock.freeze(t0);
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    session = SessionStore();
    await session.load();
    await session.save(const AuthResponse(
        accessToken: 'a', refreshToken: 'r', userId: 7, teamId: 3));
    host = _Host();
    client = ApiClient(session,
        adapter: host, offlineCache: OfflineCache(directory: () async => tmp));
  });

  tearDown(() async {
    AppClock.reset();
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  test('online: the answer is fresh, and it is kept', () async {
    final res = await client.dio.get('/clients');

    expect(res.data, [
      {'id': 1, 'fullName': 'Aisha'}
    ]);
    expect(res.extra[offlineCachedAtKey], isNull);
    expect(client.offline.value, isNull);
    expect(await client.offlineCache!.sizeInBytes(), greaterThan(0));
  });

  test('offline: the kept answer is served, marked stale with its time',
      () async {
    await client.dio.get('/clients');
    host.online = false;
    AppClock.freeze(t0.add(const Duration(hours: 1)));

    final res = await client.dio.get('/clients');

    expect(res.data, [
      {'id': 1, 'fullName': 'Aisha'}
    ]);
    expect(res.extra[offlineCachedAtKey], t0);
    expect(client.offline.value, t0);
  });

  test('offline with nothing kept: the failure is still offline', () async {
    host.online = false;
    await expectLater(
      client.dio.get('/deals'),
      throwsA(isA<DioException>().having(
          (e) => ApiFailure.from(e).kind, 'kind', ApiFailureKind.offline)),
    );
    expect(client.offline.value, isNull);
  });

  test('the next answer from the network clears the stale flag', () async {
    await client.dio.get('/clients');
    host.online = false;
    await client.dio.get('/clients');
    expect(client.offline.isStale, isTrue);

    host.online = true;
    await client.dio.get('/dashboard/summary');
    expect(client.offline.isStale, isFalse);
  });

  for (final code in [404, 500]) {
    test('a $code is the server speaking, and is never masked', () async {
      await client.dio.get('/clients/1');
      host.status = code;
      host.body = {'message': 'nope'};

      await expectLater(
        client.dio.get('/clients/1'),
        throwsA(isA<DioException>()
            .having((e) => e.response?.statusCode, 'status', code)),
      );
      expect(client.offline.isStale, isFalse);
    });
  }

  test('a 503 is the host asleep, so the kept answer stands in', () async {
    await client.dio.get('/clients/1');
    host.status = 503;
    host.body = {'message': 'unavailable'};

    final res = await client.dio.get('/clients/1');
    expect(res.statusCode, 200);
    expect(res.extra[offlineCachedAtKey], t0);
  });

  test('a cold start is still waited out before the cache is asked', () async {
    await client.dio.get('/dashboard/summary');
    host
      ..sleepyCalls = 1
      ..failure = DioExceptionType.connectionTimeout
      ..body = {'fresh': true};

    final res = await client.dio.get('/dashboard/summary');

    expect(res.data, {'fresh': true});
    expect(res.extra[offlineCachedAtKey], isNull);
    expect(host.calls.last.connectTimeout,
        greaterThan(const Duration(seconds: 60)));
  });

  test('writes are never kept, and fail as "offline write"', () async {
    await client.dio.post('/clients', data: {'fullName': 'B'});
    expect(await client.offlineCache!.sizeInBytes(), 0);

    host.online = false;
    await expectLater(
      client.dio.post('/clients', data: {'fullName': 'B'}),
      throwsA(isA<DioException>().having(
          (e) => ApiFailure.from(e).kind, 'kind', ApiFailureKind.offlineWrite)),
    );
  });

  test('auth reads are never kept', () async {
    await client.dio.get('/auth/me');
    expect(await client.offlineCache!.sizeInBytes(), 0);
  });

  test('an error response is never kept', () async {
    host.status = 500;
    await expectLater(client.dio.get('/clients'), throwsA(anything));
    expect(await client.offlineCache!.sizeInBytes(), 0);
  });

  test('signing out wipes the cache and the stale flag', () async {
    await client.dio.get('/clients');
    host.online = false;
    await client.dio.get('/clients');

    await session.clear();

    expect(client.offline.isStale, isFalse);
    expect(await client.offlineCache!.sizeInBytes(), 0);
  });

  test('another account on this phone never sees the first one\'s cache',
      () async {
    await client.dio.get('/clients');
    await session.save(const AuthResponse(
        accessToken: 'b', refreshToken: 'r', userId: 8, teamId: 3));
    host.online = false;

    await expectLater(client.dio.get('/clients'), throwsA(anything));
  });
}
