import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/app_lock/presentation/screens/app_lock_setup_screen.dart';
import 'package:real_estate_crm/features/app_lock/presentation/screens/lock_screen.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/auto_lock_options.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The fullest the lock screen gets: a pause counting down, the way out
/// after ten wrong PINs, and Forgot PIN under the pad.
Future<AppLockController> _worstCase() async {
  final repo = fakeAppLockRepository();
  await repo.save(
    1,
    AppLockRecord(
      pin: await repo.hash('123456'),
      pinLength: 6,
      failures: 10,
      retryAt: DateTime.now().add(const Duration(hours: 1)),
    ),
  );
  final lock = AppLockController(repository: repo);
  await lock.attach(1);
  return lock;
}

void main() {
  for (final locale in kAcceptanceLocales) {
    forEachAcceptanceCase('lock screen ${locale.languageCode}',
        (tester, size, brightness, scale) async {
      final lock = await _worstCase();
      await expectNoOverflow(tester, LockScreen(controller: lock),
          size: size, brightness: brightness, textScale: scale, locale: locale);
      final key = tester.getSize(find.byKey(const ValueKey('pin-key-0')));
      expect(key.shortestSide, greaterThanOrEqualTo(44));
      expect(find.byKey(const ValueKey('pin-key-0')).hitTestable(),
          findsOneWidget);
    });

    forEachAcceptanceCase('PIN setup ${locale.languageCode}',
        (tester, size, brightness, scale) async {
      final lock = AppLockController(repository: fakeAppLockRepository());
      await lock.attach(1);
      await expectNoOverflow(tester,
          AppLockSetupScreen(controller: lock, mode: PinSetupMode.enable),
          size: size, brightness: brightness, textScale: scale, locale: locale);
      expect(find.byKey(const ValueKey('pin-continue')).hitTestable(),
          findsOneWidget);
    });

    forEachAcceptanceCase('auto-lock choices ${locale.languageCode}',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AutoLockOptions(
                title: 'x',
                selected: AutoLock.fifteenMinutes,
                onSelected: (_) {},
              ),
            ),
          ),
          size: size,
          brightness: brightness,
          textScale: scale,
          locale: locale);
    });
  }
}
