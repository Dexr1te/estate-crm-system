import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/shortcuts/app_shortcuts.dart';
import 'package:real_estate_crm/core/utils/deep_links.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

import 'fakes.dart';

const _user = AuthResponse(
    userId: 1,
    fullName: 'Sultan',
    email: 's@x.kz',
    role: Role.AGENT,
    teamId: 1,
    teamName: 'Desk');

/// A restored session on a phone with a PIN: the lock is up.
Future<(AuthBloc, AppLockController)> _lockedApp() async {
  final store = FakeSecretStore();
  final repo = fakeAppLockRepository(store);
  await repo.save(1, AppLockRecord(pin: await repo.hash('1234'), pinLength: 4));
  final auth = AuthBloc(FakeAuthRepository(user: _user))..add(AuthCheckEvent());
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  final lock = AppLockController(repository: repo);
  await lock.attach(1);
  expect(lock.isLocked, isTrue);
  return (auth, lock);
}

void main() {
  test('a deep link waits behind the lock and goes on once it opens', () async {
    final (auth, lock) = await _lockedApp();
    final links = StreamController<Uri>();
    var asked = 0;
    final handler = DeepLinkHandler(
      router: GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const SizedBox()),
      ]),
      auth: auth,
      links: links.stream,
      gate: lock,
      confirmSignOut: () async {
        asked++;
        return false;
      },
    )..start();
    addTearDown(handler.dispose);

    links.add(Uri.parse('estatecrm://accept-invite?token=abc'));
    await pumpEventQueue();
    expect(asked, 0, reason: 'nothing is asked over the lock screen');

    await lock.unlock('1234');
    await pumpEventQueue();
    expect(asked, 1);
    await links.close();
  });

  test('a home-screen shortcut waits behind the lock too', () async {
    final (auth, lock) = await _lockedApp();
    final opened = <AppShortcut>[];
    final handler = ShortcutHandler(
      actions: FakeQuickActions(launchedWith: 'new_client'),
      auth: auth,
      open: opened.add,
      gate: lock,
    );
    addTearDown(handler.dispose);
    await handler.start();
    expect(opened, isEmpty);

    await lock.unlock('0000');
    expect(opened, isEmpty, reason: 'a wrong PIN opens nothing');
    await lock.unlock('1234');
    expect(opened, [AppShortcut.newClient]);
  });
}
