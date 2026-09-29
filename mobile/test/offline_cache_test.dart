import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _key(String path, {String scope = 'u1:t1', Map<String, dynamic>? q}) =>
    OfflineCache.keyFor(
        method: 'GET', path: path, query: q ?? const {}, scope: scope);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  final t0 = DateTime(2026, 9, 26, 14, 32);

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('offline_cache_test');
    AppClock.freeze(t0);
  });

  tearDown(() async {
    AppClock.reset();
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  OfflineCache cache({int maxBytes = 20 * 1024 * 1024}) =>
      OfflineCache(directory: () async => tmp, maxBytes: maxBytes);

  group('what is kept', () {
    test('reads of the main entities, and nothing else', () {
      for (final path in [
        '/clients',
        '/clients/with-details',
        '/clients/cold',
        '/clients/7',
        '/clients/7/matches',
        '/clients/7/activities',
        '/properties',
        '/properties/3',
        '/properties/3/photos',
        '/properties/3/cover',
        '/deals',
        '/deals/9',
        '/deals/9/comments',
        '/deals/9/comments/mentionable',
        '/meetings',
        '/meetings/upcoming',
        '/tasks',
        '/dashboard/summary',
      ]) {
        expect(OfflineCache.isCacheable('GET', path), isTrue, reason: path);
      }
      expect(OfflineCache.isCacheable('POST', '/clients'), isFalse);
      expect(OfflineCache.isCacheable('PUT', '/clients/7'), isFalse);
      expect(OfflineCache.isCacheable('DELETE', '/deals/9'), isFalse);
      expect(OfflineCache.isCacheable('GET', '/auth/me'), isFalse);
      expect(OfflineCache.isCacheable('GET', '/admin/users'), isFalse);
      expect(
          OfflineCache.isCacheable('GET', '/properties/3/share-link'), isFalse);
      expect(OfflineCache.isCacheable('GET', '/properties/3/photos/1/content'),
          isFalse,
          reason: 'full-size photos would blow the size cap');
    });

    test('the key tells users, teams and queries apart', () {
      expect(_key('/clients', scope: 'u1:t1'),
          isNot(_key('/clients', scope: 'u2:t1')));
      expect(_key('/clients', scope: 'u1:t1'),
          isNot(_key('/clients', scope: 'u1:t2')));
      expect(_key('/deals', q: {'status': 'NEW'}),
          isNot(_key('/deals', q: {'status': 'WON'})));
      expect(_key('/properties', q: {'a': 1, 'b': 2}),
          _key('/properties', q: {'b': 2, 'a': 1}));
      expect(_key('/properties', q: {'a': 1, 'b': null}),
          _key('/properties', q: {'a': 1}));
    });
  });

  test('an answer comes back as it went in, with when it was fresh', () async {
    final c = cache();
    await c.write(_key('/clients'), [
      {'id': 1, 'fullName': 'Aisha'}
    ]);

    final hit = await c.read(_key('/clients'));
    expect(hit!.data, [
      {'id': 1, 'fullName': 'Aisha'}
    ]);
    expect(hit.savedAt, t0);
    expect(hit.statusCode, 200);
  });

  test('bytes survive the round trip', () async {
    final c = cache();
    await c.write(_key('/properties/3/cover'), Uint8List.fromList([1, 2, 3]));
    final hit = await c.read(_key('/properties/3/cover'));
    expect(hit!.data, isA<Uint8List>());
    expect(hit.data, [1, 2, 3]);
  });

  test('another user or team never reads what this one kept', () async {
    final c = cache();
    await c.write(_key('/clients', scope: 'u1:t1'), ['mine']);
    expect(await c.read(_key('/clients', scope: 'u2:t1')), isNull);
    expect(await c.read(_key('/clients', scope: 'u1:t2')), isNull);
  });

  test('an answer older than the max age is not served, and is dropped',
      () async {
    final c = cache();
    await c.write(_key('/tasks'), ['old']);

    AppClock.freeze(t0.add(const Duration(days: 13)));
    expect(await c.read(_key('/tasks')), isNotNull);

    AppClock.freeze(t0.add(const Duration(days: 15)));
    expect(await c.read(_key('/tasks')), isNull);
    expect(await c.sizeInBytes(), 0);
  });

  test('past the size cap the least recently used entry goes first', () async {
    final payload = List.filled(100, 'x' * 10);
    final probe = cache();
    await probe.write(_key('/deals/1'), payload);
    final one = await probe.sizeInBytes();
    await probe.wipe();

    final c = cache(maxBytes: one * 2 + one ~/ 2);
    await c.write(_key('/deals/1'), payload);
    AppClock.freeze(t0.add(const Duration(minutes: 1)));
    await c.write(_key('/deals/2'), payload);
    AppClock.freeze(t0.add(const Duration(minutes: 2)));
    expect(await c.read(_key('/deals/1')), isNotNull,
        reason: 'reading /deals/1 makes /deals/2 the least recently used');

    AppClock.freeze(t0.add(const Duration(minutes: 3)));
    await c.write(_key('/deals/3'), payload);

    expect(await c.read(_key('/deals/1')), isNotNull);
    expect(await c.read(_key('/deals/2')), isNull);
    expect(await c.read(_key('/deals/3')), isNotNull);
    expect(await c.sizeInBytes(), lessThanOrEqualTo(one * 2 + one ~/ 2));
  });

  test('the index is rebuilt from disk after a restart', () async {
    await cache().write(_key('/clients/7'), {'id': 7});
    expect((await cache().read(_key('/clients/7')))!.data, {'id': 7});
  });

  test('wipe forgets everything, and the cache keeps working after', () async {
    final c = cache();
    await c.write(_key('/clients'), ['a']);
    await c.wipe();
    expect(await c.read(_key('/clients')), isNull);

    await c.write(_key('/clients'), ['b']);
    expect((await c.read(_key('/clients')))!.data, ['b']);
  });

  test('a disk that cannot be reached is a miss, never a crash', () async {
    final broken =
        OfflineCache(directory: () async => throw const FileSystemException());
    await broken.write(_key('/clients'), ['a']);
    expect(await broken.read(_key('/clients')), isNull);
    await broken.wipe();
  });

  group('the session', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
    });

    const aisha =
        AuthResponse(accessToken: 'a', refreshToken: 'r', userId: 7, teamId: 3);

    test('scopes the cache by user and team', () async {
      final session = SessionStore();
      await session.load();
      expect(session.cacheScope, isNull, reason: 'nobody is signed in');

      await session.save(aisha);
      expect(session.cacheScope, 'u7:t3');

      await session.save(aisha.copyWith(teamId: null));
      expect(session.cacheScope, 'u7:t-');
    });

    test('keeps the team across a restart', () async {
      final first = SessionStore();
      await first.load();
      await first.save(aisha);

      final second = SessionStore();
      await second.load();
      expect(second.cacheScope, 'u7:t3');
      expect((await second.getSavedUser())!.teamId, 3);
    });

    test('signing out, or signing in as someone else, wipes it', () async {
      final session = SessionStore();
      await session.load();
      var wipes = 0;
      session.addClearListener(() async => wipes++);

      await session.save(aisha);
      await session.save(aisha.copyWith(accessToken: 'b'));
      expect(wipes, 0, reason: 'a token refresh is the same person');

      await session.save(aisha.copyWith(userId: 8));
      expect(wipes, 1);

      await session.clear();
      expect(wipes, 2);
    });
  });
}
