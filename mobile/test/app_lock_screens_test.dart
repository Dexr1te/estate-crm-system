import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/app_lock_gate.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/app_lock_settings.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

const _client = 'Aigerim, +7 701 555 0101';

Future<AppLockController> _controller({String? pin}) async {
  final repo = fakeAppLockRepository();
  if (pin != null) {
    await repo.save(
        1, AppLockRecord(pin: await repo.hash(pin), pinLength: pin.length));
  }
  final lock = AppLockController(repository: repo);
  await lock.attach(1);
  return lock;
}

Widget _app(AppLockController lock) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (_, child) => AppLockGate(controller: lock, child: child!),
      home: const Scaffold(body: Center(child: Text(_client))),
    );

Widget _settings(AppLockController lock) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: AppLockSettings(controller: lock)),
    );

Future<void> _type(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.byKey(ValueKey('pin-key-$d')));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  group('the lock screen', () {
    testWidgets('hides the app until the right PIN', (tester) async {
      final lock = await _controller(pin: '1234');
      await tester.pumpWidget(_app(lock));
      expect(find.text(_client), findsNothing);
      expect(find.text('Enter your PIN'), findsOneWidget);

      final key = tester.getSize(find.byKey(const ValueKey('pin-key-5')));
      expect(key.shortestSide, greaterThanOrEqualTo(44));

      await _type(tester, '0000');
      expect(find.text('Wrong PIN'), findsOneWidget);
      expect(find.text(_client), findsNothing);

      await _type(tester, '12');
      await tester.tap(find.bySemanticsLabel('Delete'));
      await _type(tester, '234');
      expect(find.text(_client), findsOneWidget);
    });

    testWidgets('five wrong PINs pause the pad and say for how long',
        (tester) async {
      final lock = await _controller(pin: '1234');
      await tester.pumpWidget(_app(lock));
      for (var i = 0; i < 5; i++) {
        await _type(tester, '0000');
      }
      expect(find.textContaining('Try again in 0:30'), findsOneWidget);
      await _type(tester, '1234');
      expect(find.text(_client), findsNothing);
    });

    testWidgets('Forgot PIN explains, then signs out', (tester) async {
      final lock = await _controller(pin: '1234');
      var signedOut = false;
      lock.onSignOut = () async => signedOut = true;
      await tester.pumpWidget(_app(lock));

      await tester.tap(find.text('Forgot PIN?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('client data saved on this phone'),
          findsOneWidget);
      await tester.tap(find.text('Sign out and sign in again'));
      await tester.pumpAndSettle();
      expect(signedOut, isTrue);
      expect(lock.enabled, isFalse);
    });

    testWidgets('ten wrong PINs put the way out on the screen', (tester) async {
      final repo = fakeAppLockRepository();
      await repo.save(
          1,
          AppLockRecord(
              pin: await repo.hash('1234'), pinLength: 4, failures: 10));
      final lock = AppLockController(repository: repo);
      await lock.attach(1);
      await tester.pumpWidget(_app(lock));
      expect(find.text('Sign out and sign in again'), findsOneWidget);
      expect(find.textContaining('Too many wrong PINs'), findsOneWidget);
    });
  });

  group('the privacy cover', () {
    testWidgets('covers the app when it goes inactive, with a lock set',
        (tester) async {
      final lock = await _controller(pin: '1234');
      await lock.unlock('1234');
      await tester.pumpWidget(_app(lock));
      expect(find.text(_client), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const ValueKey('privacy-cover')), findsOneWidget);
      expect(find.text(_client), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text(_client), findsOneWidget);
    });

    testWidgets('leaves the app alone without one', (tester) async {
      final lock = await _controller();
      await tester.pumpWidget(_app(lock));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const ValueKey('privacy-cover')), findsNothing);
      expect(find.text(_client), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  });

  group('setting it up', () {
    testWidgets('too short, then a mismatch, then on with a timeout',
        (tester) async {
      final lock = await _controller();
      await tester.pumpWidget(_settings(lock));
      await tester.tap(find.byKey(const ValueKey('app-lock-switch')));
      await tester.pumpAndSettle();
      expect(find.text('Choose a PIN'), findsOneWidget);

      await _type(tester, '123');
      await tester.tap(find.byKey(const ValueKey('pin-continue')));
      await tester.pumpAndSettle();
      expect(find.text('The PIN needs 4 to 6 digits.'), findsOneWidget);

      await _type(tester, '1234');
      await tester.tap(find.byKey(const ValueKey('pin-continue')));
      await tester.pumpAndSettle();
      expect(find.text('Enter the PIN again'), findsOneWidget);
      await _type(tester, '1235');
      expect(find.text('The PINs do not match. Try again.'), findsOneWidget);
      expect(find.text('Choose a PIN'), findsOneWidget);

      await _type(tester, '123456');
      await _type(tester, '123456');
      await tester.tap(find.byKey(const ValueKey('auto-lock-fiveMinutes')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('pin-turn-on')));
      await tester.pumpAndSettle();

      expect(lock.enabled, isTrue);
      expect(lock.pinLength, 6);
      expect(lock.autoLock, AutoLock.fiveMinutes);
      expect(find.text('App lock is on'), findsOneWidget);
      expect(find.text('Change PIN'), findsOneWidget);
    });

    testWidgets('changing the PIN wants the current one first', (tester) async {
      final lock = await _controller(pin: '1234');
      await lock.unlock('1234');
      await tester.pumpWidget(_settings(lock));
      await tester.tap(find.text('Change PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your current PIN'), findsOneWidget);

      await _type(tester, '9999');
      expect(find.text('Wrong PIN'), findsOneWidget);
      await _type(tester, '1234');
      expect(find.text('Choose a PIN'), findsOneWidget);
      await _type(tester, '5678');
      await tester.tap(find.byKey(const ValueKey('pin-continue')));
      await tester.pumpAndSettle();
      await _type(tester, '5678');

      expect(find.text('PIN changed'), findsOneWidget);
      expect(await lock.verify('5678'), PinCheck.accepted);
    });

    testWidgets('turning it off wants the current PIN', (tester) async {
      final lock = await _controller(pin: '1234');
      await lock.unlock('1234');
      await tester.pumpWidget(_settings(lock));
      await tester.tap(find.byKey(const ValueKey('app-lock-switch')));
      await tester.pumpAndSettle();

      await _type(tester, '4321');
      expect(find.text('Wrong PIN'), findsOneWidget);
      expect(lock.enabled, isTrue);
      await _type(tester, '1234');
      expect(lock.enabled, isFalse);
      expect(find.text('App lock is off'), findsOneWidget);
    });
  });
}
