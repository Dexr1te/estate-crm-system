import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/features/app_lock/data/app_lock_repository_impl.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';

import 'fakes.dart';

class _Clock {
  DateTime now = DateTime(2026, 9, 29, 10);
  void advance(Duration d) => now = now.add(d);
}

void main() {
  late FakeSecretStore store;
  late _Clock clock;

  AppLockController controller() => AppLockController(
      repository: fakeAppLockRepository(store), now: () => clock.now);

  /// A phone with [pin] already set for user 1, as a previous run left it.
  Future<void> seed(String pin, AutoLock autoLock) async {
    final repo = fakeAppLockRepository(store);
    await repo.save(
        1,
        AppLockRecord(
            pin: await repo.hash(pin),
            pinLength: pin.length,
            autoLock: autoLock));
  }

  void background(AppLockController c) {
    c.lifecycleChanged(AppLifecycleState.inactive);
    c.lifecycleChanged(AppLifecycleState.hidden);
    c.lifecycleChanged(AppLifecycleState.paused);
  }

  void resume(AppLockController c) {
    c.lifecycleChanged(AppLifecycleState.hidden);
    c.lifecycleChanged(AppLifecycleState.inactive);
    c.lifecycleChanged(AppLifecycleState.resumed);
  }

  setUp(() {
    store = FakeSecretStore();
    clock = _Clock();
  });

  group('when it locks', () {
    test('a cold start that restores a session locks', () async {
      await seed('1234', AutoLock.fiveMinutes);
      final lock = controller();
      expect(lock.isOpen, isFalse, reason: 'closed until the session is known');
      await lock.attach(1);
      expect(lock.isLocked, isTrue);
      expect(lock.isOpen, isFalse);
      expect(await lock.unlock('1234'), PinCheck.accepted);
      expect(lock.isLocked, isFalse);
      expect(lock.isOpen, isTrue);
    });

    test('no PIN, no lock', () async {
      final lock = controller();
      await lock.attach(1);
      expect(lock.isLocked, isFalse);
      background(lock);
      clock.advance(const Duration(hours: 1));
      resume(lock);
      expect(lock.isLocked, isFalse);
    });

    test('back before the timeout stays open; at the timeout it locks',
        () async {
      await seed('1234', AutoLock.fiveMinutes);
      final lock = controller();
      await lock.attach(1);
      await lock.unlock('1234');

      background(lock);
      clock.advance(const Duration(minutes: 4, seconds: 59));
      resume(lock);
      expect(lock.isLocked, isFalse);

      background(lock);
      clock.advance(const Duration(minutes: 5));
      resume(lock);
      expect(lock.isLocked, isTrue);
    });

    test('"immediately" locks after any trip to the background', () async {
      await seed('1234', AutoLock.immediately);
      final lock = controller();
      await lock.attach(1);
      await lock.unlock('1234');
      background(lock);
      resume(lock);
      expect(lock.isLocked, isTrue);
    });

    test('a pull of the notification shade covers but does not lock', () async {
      await seed('1234', AutoLock.immediately);
      final lock = controller();
      await lock.attach(1);
      await lock.unlock('1234');
      lock.lifecycleChanged(AppLifecycleState.inactive);
      expect(lock.isCovered, isTrue);
      lock.lifecycleChanged(AppLifecycleState.resumed);
      expect(lock.isCovered, isFalse);
      expect(lock.isLocked, isFalse);
    });

    test('signing in with a password does not then ask for a PIN', () async {
      await seed('1234', AutoLock.immediately);
      final lock = controller();
      await lock.attach(null);
      await lock.attach(1);
      expect(lock.isLocked, isFalse);
    });
  });

  group('wrong PINs', () {
    test('five wrong ones start a pause that survives a restart', () async {
      await seed('1234', AutoLock.immediately);
      var lock = controller();
      await lock.attach(1);
      for (var i = 0; i < 4; i++) {
        expect(await lock.unlock('0000'), PinCheck.wrong);
        expect(lock.retryIn, isNull);
      }
      expect(await lock.unlock('0000'), PinCheck.wrong);
      expect(lock.retryIn, const Duration(seconds: 30));
      expect(await lock.unlock('1234'), PinCheck.throttled,
          reason: 'even the right PIN waits out the pause');

      lock = controller();
      await lock.attach(1);
      expect(lock.isLocked, isTrue);
      expect(lock.failures, 5);
      expect(lock.retryIn, const Duration(seconds: 30));

      clock.advance(const Duration(seconds: 30));
      expect(await lock.unlock('0000'), PinCheck.wrong);
      expect(lock.retryIn, const Duration(minutes: 1));
      clock.advance(const Duration(minutes: 1));
      expect(await lock.unlock('0000'), PinCheck.wrong);
      expect(lock.retryIn, const Duration(minutes: 5));
    });

    test('the right PIN clears the count', () async {
      await seed('1234', AutoLock.immediately);
      final lock = controller();
      await lock.attach(1);
      await lock.unlock('0000');
      await lock.unlock('0000');
      await lock.unlock('1234');
      expect(lock.failures, 0);
      expect((await fakeAppLockRepository(store).read(1))!.failures, 0);
    });

    test('the delay grows and then holds at an hour', () {
      expect(AppLockController.delayAfter(4), isNull);
      expect(AppLockController.delayAfter(5), const Duration(seconds: 30));
      expect(AppLockController.delayAfter(6), const Duration(minutes: 1));
      expect(AppLockController.delayAfter(7), const Duration(minutes: 5));
      expect(AppLockController.delayAfter(10), const Duration(hours: 1));
      expect(AppLockController.delayAfter(40), const Duration(hours: 1));
    });

    test(
        'ten wrong ones offer the way out, which takes the PIN, the session '
        'and the offline cache', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final session = SessionStore();
      await session.save(const AuthResponse(
          accessToken: 'a',
          refreshToken: 'r',
          tokenType: 'Bearer',
          userId: 1,
          fullName: 'Sultan',
          email: 's@x.kz',
          role: Role.AGENT));
      final dir = await Directory.systemTemp.createTemp('lock_cache');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });
      final cache = OfflineCache(directory: () async => dir);
      ApiClient(session, offlineCache: cache);
      await cache.write('u1:t-|GET /clients', {'name': 'Aigerim'});
      expect(await cache.sizeInBytes(), greaterThan(0));

      await seed('1234', AutoLock.immediately);
      final lock = controller()..onSignOut = session.clear;
      await lock.attach(1);
      for (var i = 0; i < 10; i++) {
        clock.advance(const Duration(hours: 1));
        await lock.unlock('0000');
      }
      expect(lock.canSignOut, isTrue);

      await lock.signOut();
      expect(store.values, isEmpty);
      expect(session.isLoggedIn, isFalse);
      expect(await cache.sizeInBytes(), 0);
      expect(lock.isLocked, isTrue, reason: 'up until the session has ended');
      await lock.attach(null);
      expect(lock.isLocked, isFalse);
    });
  });

  group('whose lock it is', () {
    test('signing out takes the PIN with it', () async {
      await seed('1234', AutoLock.immediately);
      final lock = controller();
      await lock.attach(1);
      await lock.attach(null);
      expect(store.values, isEmpty);
    });

    test('another account on the same phone starts without a lock', () async {
      final lock = controller();
      await lock.attach(1);
      await lock.enable('1234', AutoLock.oneMinute);
      expect(store.values.keys, [AppLockRepositoryImpl.keyFor(1)]);
      await lock.attach(2);
      expect(lock.enabled, isFalse);
      expect(store.values, isEmpty);
    });
  });

  group('changing and removing', () {
    test('change and turn off both want the current PIN', () async {
      final lock = controller();
      await lock.attach(1);
      await lock.enable('1234', AutoLock.immediately);

      expect(await lock.changePin('9999', '567890'), PinCheck.wrong);
      expect(await lock.changePin('1234', '567890'), PinCheck.accepted);
      expect(lock.pinLength, 6);
      expect(await lock.disable('1234'), PinCheck.wrong);
      expect(lock.enabled, isTrue);
      expect(await lock.disable('567890'), PinCheck.accepted);
      expect(lock.enabled, isFalse);
      expect(store.values, isEmpty);
    });
  });
}
