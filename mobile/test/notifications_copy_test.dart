import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/notifications/presentation/bloc/unread_count_bloc.dart';
import 'package:real_estate_crm/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Every kind of notification reads as a finished sentence in English, Russian
/// and Kazakh — no placeholder left showing, no raw status name — and counts
/// agree with their nouns. The unread count is polled only on a timer the
/// caller hands in, and stops when told.

final _now = DateTime(2026, 9, 26, 15, 30);

AppNotification _n(NotificationType type, Map<String, dynamic> params,
        {int id = 1, int? target = 9, DateTime? at}) =>
    AppNotification(
        id: id,
        type: type,
        targetId: target,
        params: params,
        createdAt: at ?? _now);

final _everyType = <AppNotification>[
  _n(NotificationType.taskAssigned,
      {'actorName': 'Asel', 'taskTitle': 'Call Irina'}),
  _n(NotificationType.recordsHandedOver, {
    'fromName': 'Timur',
    'clients': 2,
    'properties': 1,
    'deals': 1,
    'meetings': 3,
    'tasks': 1,
  }),
  _n(NotificationType.joinRequest,
      {'actorName': 'Asel', 'teamName': 'Almaty Realty'}),
  _n(NotificationType.joinAccepted,
      {'agentName': 'Madina', 'teamName': 'Almaty Realty'}),
  _n(NotificationType.newMatch, {
    'propertyTitle': 'Dostyk 5',
    'buyerCount': 4,
    'buyerNames': ['Aigerim', 'Bolat', 'Daniyar'],
  }),
  _n(NotificationType.priceDropMatch, {
    'propertyTitle': 'Dostyk 5',
    'oldPrice': '50000000',
    'newPrice': '42000000',
    'buyerCount': 1,
    'buyerNames': ['Aigerim'],
  }),
  _n(NotificationType.dealStatusChanged, {
    'actorName': 'Asel',
    'dealTitle': 'Dostyk flat',
    'fromStatus': 'LEAD',
    'toStatus': 'NEGOTIATION',
  }),
  _n(NotificationType.unknown, const {}),
];

class _FakeTimer implements Timer {
  final void Function(Timer) onTick;
  bool cancelled = false;
  _FakeTimer(this.onTick);

  void fire() => onTick(this);

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

void main() {
  setUp(() => AppClock.freeze(_now));
  tearDown(AppClock.reset);

  group('every type reads as a sentence', () {
    for (final locale in kAcceptanceLocales) {
      test(locale.languageCode, () async {
        final l10n = await AppLocalizations.delegate.load(locale);
        for (final n in _everyType) {
          final copy = notificationCopy(l10n, n);
          final text = '${copy.title} ${copy.detail ?? ''}';
          expect(copy.title.trim(), isNotEmpty, reason: '${n.type}');
          expect(text, isNot(contains('{')), reason: '${n.type}: $text');
          expect(text, isNot(matches(RegExp(r'[A-Z]{2,}_[A-Z]+'))),
              reason: '${n.type} shows a raw name: $text');
        }
        final names = [
          for (final n in _everyType.take(7)) notificationCopy(l10n, n).title,
        ];
        expect(names[0], contains('Call Irina'));
        expect(names[2], contains('Almaty Realty'));
        expect(names[3], contains('Madina'));
        expect(names[4], contains('Dostyk 5'));
        expect(names[5], contains(r'$42.0M'));
        expect(names[5], contains(r'$50.0M'));
        expect(names[6], contains('Dostyk flat'));
        expect(names[6], contains(l10n.coreStatusNegotiation));
      });
    }

    test('counts agree with their nouns', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      final kk = await AppLocalizations.delegate.load(const Locale('kk'));
      AppNotification handed(int clients) => _n(
          NotificationType.recordsHandedOver,
          {'fromName': 'Timur', 'clients': clients});

      expect(
          notificationCopy(en, handed(1)).title, 'Timur handed you 1 record');
      expect(notificationCopy(en, handed(1)).detail, '1 client');
      expect(notificationCopy(en, handed(5)).detail, '5 clients');
      expect(notificationCopy(ru, handed(1)).detail, '1 клиент');
      expect(notificationCopy(ru, handed(3)).detail, '3 клиента');
      expect(notificationCopy(ru, handed(5)).detail, '5 клиентов');
      expect(notificationCopy(ru, handed(21)).title,
          'Timur передаёт вам 21 запись');
      expect(notificationCopy(kk, handed(5)).detail, '5 клиент');

      final match = notificationCopy(en, _everyType[4]);
      expect(match.detail, 'Fits 4 buyers: Aigerim, Bolat, Daniyar and 1 more');
      expect(notificationCopy(en, _everyType[5]).detail, 'Fits Aigerim');
    });

    test('a missing actor still reads as somebody', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final copy = notificationCopy(
          en, _n(NotificationType.taskAssigned, {'taskTitle': 'Call Irina'}));
      expect(copy.title, 'Someone gave you a task: Call Irina');
    });
  });

  group('where a tap goes', () {
    test('to the record, or the list that holds it', () {
      String? go(AppNotification n) => notificationTarget(n)?.location;
      expect(go(_everyType[0]), '/tasks');
      expect(go(_everyType[1]), '/clients');
      expect(go(_everyType[2]), '/onboarding/waiting');
      expect(go(_everyType[3]), '/team-console');
      expect(go(_everyType[4]), '/properties/9');
      expect(go(_everyType[5]), '/properties/9');
      expect(go(_everyType[6]), '/deals/9');
      expect(go(_everyType[7]), isNull);
      expect(
          go(_n(NotificationType.recordsHandedOver, {'deals': 2})), '/deals');
    });
  });

  group('the unread poll', () {
    test('ticks on the timer it is given and stops when told', () async {
      _FakeTimer? timer;
      Duration? every;
      var refreshed = 0;
      final poller = UnreadCountPoller(
        refresh: () async => refreshed++,
        interval: const Duration(seconds: 60),
        periodic: (d, tick) {
          every = d;
          return timer = _FakeTimer(tick);
        },
      );
      poller.start();
      expect(poller.isRunning, isTrue);
      expect(every, const Duration(seconds: 60));

      timer!.fire();
      timer!.fire();
      expect(refreshed, 2);

      poller.stop();
      expect(timer!.cancelled, isTrue);
      expect(poller.isRunning, isFalse);
    });

    test('never starts without an interval, as under test', () {
      var created = 0;
      final poller = UnreadCountPoller(
        refresh: () async {},
        interval: Injector.notificationsPollInterval,
        periodic: (d, tick) {
          created++;
          return _FakeTimer(tick);
        },
      );
      poller.start();
      expect(created, 0);
      expect(poller.isRunning, isFalse);
    });

    test('the badge follows the repository', () async {
      final repo = FakeNotificationsRepository([
        _n(NotificationType.taskAssigned, const {}, id: 1),
        _n(NotificationType.taskAssigned, const {}, id: 2),
      ]);
      final bloc = UnreadCountBloc(repo);
      addTearDown(bloc.close);

      bloc.add(UnreadCountRefreshEvent());
      await expectLater(bloc.stream, emits(2));
      await repo.markRead(1);
      await expectLater(bloc.stream, emits(1));
    });
  });

  group('fits every screen', () {
    setUp(() {
      Injector.notificationsRepository = FakeNotificationsRepository([
        for (var i = 0; i < _everyType.length; i++)
          _everyType[i].copyWith(
              id: i + 1,
              createdAt: _now.subtract(Duration(hours: i * 7)),
              readAt: i.isEven ? null : _now),
      ]);
    });
    tearDown(
        () => Injector.notificationsRepository = FakeNotificationsRepository());

    forEachAcceptanceCase('notifications',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, const NotificationsScreen(),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('notifications — 320 wide, 1.5x, ${locale.languageCode}',
          (tester) async {
        await expectNoOverflow(tester, const NotificationsScreen(),
            size: const Size(320, 568),
            brightness: Brightness.light,
            textScale: 1.5,
            locale: locale);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
