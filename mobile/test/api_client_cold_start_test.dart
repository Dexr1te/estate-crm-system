import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A host that is asleep for its first [failures] calls, the way the backend is
/// whenever nobody has used the app for a while.
class _SleepingHost implements HttpClientAdapter {
  _SleepingHost({required this.failures, required this.failure});

  final int failures;
  final DioExceptionType failure;

  final List<RequestOptions> attempts = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    attempts.add(options);

    if (attempts.length <= failures) {
      throw DioException(requestOptions: options, type: failure);
    }
    return ResponseBody.fromString(jsonEncode({'ok': true}), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

Future<ApiClient> _client(_SleepingHost host) async {
  FlutterSecureStorage.setMockInitialValues({});
  SharedPreferences.setMockInitialValues({});
  final session = SessionStore();
  await session.load();
  return ApiClient(session, adapter: host);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a read that times out while the host wakes up is retried, patiently',
      () async {
    final host = _SleepingHost(
        failures: 1, failure: DioExceptionType.connectionTimeout);
    final client = await _client(host);

    final res = await client.dio.get('/dashboard/summary');

    expect(res.statusCode, 200);
    expect(host.attempts, hasLength(2));
    expect(host.attempts.last.connectTimeout, greaterThan(const Duration(seconds: 60)),
        reason: 'the second attempt has to outlast a cold start, or it buys '
            'nothing over the first');
  });

  test('a write is replayed only when nothing reached the server', () async {
    final refused = _SleepingHost(
        failures: 1, failure: DioExceptionType.connectionError);
    final answered = _SleepingHost(
        failures: 1, failure: DioExceptionType.receiveTimeout);

    final onRefusedConnection = await _client(refused);
    await onRefusedConnection.dio.post('/clients', data: {'fullName': 'A'});
    expect(refused.attempts, hasLength(2),
        reason: 'the connection never opened, so the client cannot have been '
            'created once already');

    final onSilence = await _client(answered);
    await expectLater(
        onSilence.dio.post('/clients', data: {'fullName': 'A'}),
        throwsA(isA<DioException>()));
    expect(answered.attempts, hasLength(1),
        reason: 'the request did go out — a replay risks a second client under '
            'the same name, which is worse than the error');
  });

  test('a host that never wakes up fails instead of looping', () async {
    final host = _SleepingHost(
        failures: 99, failure: DioExceptionType.connectionTimeout);
    final client = await _client(host);

    await expectLater(
        client.dio.get('/dashboard/summary'), throwsA(isA<DioException>()));
    expect(host.attempts, hasLength(2), reason: 'one try, one second chance');
  });
}
