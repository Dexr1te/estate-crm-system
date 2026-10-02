import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/day_agenda.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_history_card.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_source_badge.dart';
import 'package:real_estate_crm/features/open_houses/presentation/screens/open_house_screen.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/property_open_houses_card.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/schedule_open_house_sheet.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/visitor_sign_in_sheet.dart';

import 'open_house_fakes.dart';
import 'responsive_harness.dart';

/// Open houses: scheduled on a listing, a sign-in sheet at the door that
/// keeps going from one visitor to the next, a summary afterwards, and the
/// event wherever the agent looks — the listing, the calendar, the client's
/// history.

final _now = DateTime(2026, 10, 4, 12, 30);

final _visitors = [
  const OpenHouseVisitor(
    id: 11,
    openHouseId: 1,
    fullName: 'Saule Nurlanovna Abdrakhmanova-Seitkali',
    phone: '+7 701 555 12 34',
    interest: OpenHouseInterest.interested,
    note: 'Wants a quiet floor, will come back with her husband on Sunday '
        'and asks whether the parking space is sold with the flat.',
    clientId: 21,
    clientVisible: true,
    clientName: 'Saule Nurlanovna',
    newClient: true,
    canRemove: true,
  ),
  const OpenHouseVisitor(
    id: 12,
    openHouseId: 1,
    fullName: 'Arman Bekov',
    phone: '+7 702 111 22 33',
    interest: OpenHouseInterest.justLooking,
    clientId: 22,
    clientAgentName: 'Timur Aliev-Konstantinopolsky',
  ),
];

OpenHouse _openHouse({
  int id = 1,
  DateTime? startsAt,
  int hours = 3,
  List<OpenHouseVisitor>? visitors,
  bool canEdit = true,
}) {
  final start = startsAt ?? DateTime(2026, 10, 4, 12);
  final list = visitors ?? _visitors;
  return OpenHouse(
    id: id,
    propertyId: 7,
    propertyTitle: 'Severny Residence, apartment 84 on the twelfth floor',
    propertyAddress: 'Dostyk avenue 5, Medeu district, Almaty',
    agentId: 5,
    agentName: 'Aigul Bekova',
    startsAt: start,
    endsAt: start.add(Duration(hours: hours)),
    note: 'Keys with the concierge. Parking on the left side.',
    visitorCount: list.length,
    newClientCount: list.where((v) => v.newClient).length,
    interestedCount:
        list.where((v) => v.interest == OpenHouseInterest.interested).length,
    canEdit: canEdit,
    visitors: list,
  );
}

late FakeOpenHousesRepository _repo;

Widget _page(Widget child) => Scaffold(
      body: ListView(padding: const EdgeInsets.all(16), children: [child]),
    );

Widget _signInSheet() => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AppSheetShell(
          title: 'Add visitor',
          child: VisitorSignInForm(openHouseId: 1, onSignedIn: (_) {}),
        ),
      ),
    );

Widget _scheduleSheet({OpenHouse? existing}) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AppSheetShell(
          title: 'Schedule',
          child: ScheduleOpenHouseForm(propertyId: 7, existing: existing),
        ),
      ),
    );

Widget _agenda({ValueChanged<OpenHouse>? onOpen}) => _page(DayAgenda(
      day: DateTime(2026, 10, 4),
      now: _now,
      page: CalendarPage(openHouses: [_openHouse()]),
      failure: null,
      onRetry: () {},
      onOpenMeeting: (_) {},
      onOpenTask: (_) {},
      onToggleTask: (_) {},
      onOpenOpenHouse: onOpen,
    ));

Future<void> _pump(WidgetTester tester, Widget child) async {
  await expectNoOverflow(tester, child,
      size: const Size(390, 844), brightness: Brightness.light, textScale: 1.0);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = FakeOpenHousesRepository(
      openHouses: [
        _openHouse(),
        _openHouse(
            id: 2,
            startsAt: DateTime(2026, 10, 11, 11),
            visitors: const [],
            hours: 2),
        _openHouse(id: 3, startsAt: DateTime(2026, 9, 20, 12)),
      ],
      knownPhones: {'77021112233'},
    );
    Injector.openHousesRepository = _repo;
  });
  tearDown(AppClock.reset);

  group('layout', () {
    forEachAcceptanceCase('open house screen',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, const OpenHouseScreen(id: 1),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('sign-in sheet',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, _signInSheet(),
          size: size, brightness: brightness, textScale: scale);
    });

    forEachAcceptanceCase('schedule sheet',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, _scheduleSheet(existing: _openHouse()),
          size: size, brightness: brightness, textScale: scale);
    });

    forEachAcceptanceCase('listing card',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester, _page(const PropertyOpenHousesCard(propertyId: 7)),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('everything renders in ${locale.languageCode}',
          (tester) async {
        for (final child in [
          const OpenHouseScreen(id: 1),
          _page(const PropertyOpenHousesCard(propertyId: 7)),
          _signInSheet(),
          _scheduleSheet(),
          _agenda(),
        ]) {
          await expectNoOverflow(tester, child,
              size: const Size(320, 568),
              brightness: Brightness.dark,
              textScale: 1.5,
              locale: locale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  group('the open house', () {
    testWidgets('shows when, who holds it, the summary and the sheet',
        (tester) async {
      await _pump(tester, const OpenHouseScreen(id: 1));

      expect(find.text('Sun, Oct 4 · 12:00–15:00'), findsOneWidget);
      expect(find.text('Held by Aigul Bekova'), findsOneWidget);
      expect(find.text('On now'), findsOneWidget);
      expect(find.text('Visitors'), findsOneWidget);
      expect(find.text('New clients'), findsOneWidget);
      expect(find.text('Interested'), findsWidgets);
      expect(
          find.text('Saule Nurlanovna Abdrakhmanova-Seitkali'), findsOneWidget);
      expect(find.text('New client'), findsOneWidget);
      expect(find.text('Already a client'), findsOneWidget);
      expect(find.text('Just looking'), findsOneWidget);
      expect(
          find.text('Client of Timur Aliev-Konstantinopolsky'), findsOneWidget,
          reason: "a colleague's client is named, not opened");
      expect(find.byKey(const ValueKey('visitor-remove-11')), findsOneWidget);
      expect(find.byKey(const ValueKey('visitor-remove-12')), findsNothing,
          reason: 'only the lines the user may take off offer it');
    });

    testWidgets('a past open house with nobody is an empty sheet, not live',
        (tester) async {
      _repo.openHouses
        ..clear()
        ..add(_openHouse(
            startsAt: DateTime(2026, 9, 1, 12),
            visitors: const [],
            canEdit: false));
      await _pump(tester, const OpenHouseScreen(id: 1));

      expect(find.text('Nobody has signed in yet'), findsOneWidget);
      expect(find.text('On now'), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing,
          reason: 'a colleague cannot move it');
    });

    testWidgets('a failure to load says so and can be retried', (tester) async {
      _repo.failWith = Exception('offline');
      await _pump(tester, const OpenHouseScreen(id: 1));
      expect(find.text('Could not load the open house'), findsOneWidget);

      _repo.failWith = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Arman Bekov'), findsOneWidget);
    });

    testWidgets('adding visitors one after another from the screen',
        (tester) async {
      _repo.openHouses[0] = _openHouse(visitors: const []);
      await _pump(tester, const OpenHouseScreen(id: 1));

      await tester.tap(find.byKey(const ValueKey('open-house-add-visitor')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('visitor-name')), 'Dana Seitova');
      await tester.enterText(
          find.byKey(const ValueKey('visitor-phone')), '+7 705 000 11 22');
      await tester.tap(find.byKey(const ValueKey('visitor-save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('visitor-name')), findsNothing,
          reason: 'Save closes the sheet');
      expect(find.text('Dana Seitova'), findsOneWidget,
          reason: 'the screen reads the sheet again');
    });

    testWidgets('removing a visitor asks first', (tester) async {
      await _pump(tester, const OpenHouseScreen(id: 1));

      await tester
          .ensureVisible(find.byKey(const ValueKey('visitor-remove-11')));
      await tester.tap(find.byKey(const ValueKey('visitor-remove-11')));
      await tester.pumpAndSettle();
      expect(find.textContaining('comes off the sheet'), findsOneWidget);
      await tester.tap(find.text('Remove visitor').last);
      await tester.pumpAndSettle();

      expect(_repo.removed, [11]);
      expect(
          find.text('Saule Nurlanovna Abdrakhmanova-Seitkali'), findsNothing);
    });

    testWidgets('an open house with visitors is not offered for cancelling',
        (tester) async {
      await _pump(tester, const OpenHouseScreen(id: 1));

      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('People have signed in, so it cannot be cancelled'),
          findsOneWidget);
      expect(_repo.deleted, isEmpty);
    });
  });

  group('the sign-in sheet', () {
    testWidgets('save and next clears it for the next visitor', (tester) async {
      final added = <OpenHouseVisitor>[];
      await _pump(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: VisitorSignInForm(openHouseId: 2, onSignedIn: added.add),
            ),
          ));

      await tester.enterText(
          find.byKey(const ValueKey('visitor-name')), '  Dana Seitova ');
      await tester.enterText(
          find.byKey(const ValueKey('visitor-phone')), '+7 705 000 11 22');
      await tester
          .tap(find.byKey(const ValueKey('visitor-interest-interested')));
      await tester.enterText(
          find.byKey(const ValueKey('visitor-note')), 'Two bedrooms');
      await tester.tap(find.byKey(const ValueKey('visitor-save-next')));
      await tester.pumpAndSettle();

      expect(_repo.signedIn.single.fullName, 'Dana Seitova');
      expect(_repo.signedIn.single.phone, '+7 705 000 11 22');
      expect(_repo.signedIn.single.interest, OpenHouseInterest.interested);
      expect(_repo.signedIn.single.note, 'Two bedrooms');
      expect(added, hasLength(1));
      expect(find.text('Dana Seitova signed in'), findsOneWidget);
      expect(find.text('New client'), findsOneWidget);

      final name = tester.widget<EditableText>(find.descendant(
          of: find.byKey(const ValueKey('visitor-name')),
          matching: find.byType(EditableText)));
      expect(name.controller.text, isEmpty);
      expect(name.focusNode.hasFocus, isTrue,
          reason: 'the cursor is back in the name for the next one');

      await tester.enterText(
          find.byKey(const ValueKey('visitor-name')), 'Arman');
      await tester.enterText(
          find.byKey(const ValueKey('visitor-phone')), '8 702 111 22 33');
      await tester.tap(find.byKey(const ValueKey('visitor-save-next')));
      await tester.pumpAndSettle();
      expect(find.text('Arman signed in'), findsOneWidget);
      expect(find.text('Already a client'), findsOneWidget,
          reason: 'a number the agency knows is that client');
      expect(_repo.signedIn.last.interest, isNull,
          reason: 'the interest starts unanswered for each visitor');
    });

    testWidgets('a name and a real number are needed', (tester) async {
      await _pump(tester, _signInSheet());

      await tester.tap(find.byKey(const ValueKey('visitor-save-next')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter a phone number'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('visitor-name')), 'A');
      await tester.enterText(
          find.byKey(const ValueKey('visitor-phone')), '12-34');
      await tester.tap(find.byKey(const ValueKey('visitor-save-next')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a phone number'), findsOneWidget);
      expect(_repo.signedIn, isEmpty);
    });

    testWidgets('the same number twice is refused in words', (tester) async {
      await _pump(tester, _signInSheet());

      await tester.enterText(
          find.byKey(const ValueKey('visitor-name')), 'Saule again');
      await tester.enterText(
          find.byKey(const ValueKey('visitor-phone')), '87015551234');
      await tester.tap(find.byKey(const ValueKey('visitor-save-next')));
      await tester.pumpAndSettle();

      expect(find.text('This number has already signed in'), findsOneWidget);
      expect(_repo.signedIn, isEmpty);
    });
  });

  group('scheduling', () {
    testWidgets('a new open house starts tomorrow at noon for two hours',
        (tester) async {
      await _pump(tester, _scheduleSheet());

      await tester.enterText(find.byType(TextFormField), ' Bring keys ');
      await tester.tap(find.byKey(const ValueKey('open-house-save')));
      await tester.pumpAndSettle();

      final draft = _repo.created.single;
      expect(draft.startsAt, DateTime(2026, 10, 5, 12));
      expect(draft.endsAt, DateTime(2026, 10, 5, 14));
      expect(draft.note, 'Bring keys');
    });

    testWidgets('editing keeps its times and sends them back', (tester) async {
      await _pump(tester, _scheduleSheet(existing: _openHouse(id: 2)));

      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('15:00'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('open-house-save')));
      await tester.pumpAndSettle();
      expect(_repo.created, isEmpty);
      expect(_repo.openHouses.firstWhere((o) => o.id == 2).endsAt,
          DateTime(2026, 10, 4, 15));
    });
  });

  group('on the listing', () {
    testWidgets('upcoming soonest first, then past, each with its visitors',
        (tester) async {
      await _pump(tester, _page(const PropertyOpenHousesCard(propertyId: 7)));

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      final today = find.byKey(const ValueKey('open-house-row-1'));
      final next = find.byKey(const ValueKey('open-house-row-2'));
      final past = find.byKey(const ValueKey('open-house-row-3'));
      expect(tester.getTopLeft(today).dy, lessThan(tester.getTopLeft(next).dy));
      expect(tester.getTopLeft(next).dy, lessThan(tester.getTopLeft(past).dy));
      expect(find.text('On now'), findsOneWidget);
      expect(find.text('No visitors · Aigul Bekova'), findsOneWidget);
      expect(find.text('2 visitors · Aigul Bekova'), findsNWidgets(2));
    });

    testWidgets('a listing with none invites the first', (tester) async {
      _repo.openHouses.clear();
      await _pump(tester, _page(const PropertyOpenHousesCard(propertyId: 7)));

      expect(find.textContaining('No open houses yet'), findsOneWidget);
      expect(find.byKey(const ValueKey('open-house-schedule')), findsOneWidget);
    });
  });

  group('in the calendar', () {
    test('an open house is on the day it starts, with its own marker', () {
      final page = CalendarPage(openHouses: [_openHouse()]);
      final day = DateTime(2026, 10, 4);

      expect(page.openHousesOn(day), hasLength(1));
      expect(page.countOn(day), 1);
      expect(page.markersOn(day, _now), [CalendarMarker.openHouse]);
      expect(page.openHousesOn(DateTime(2026, 10, 5)), isEmpty);
    });

    testWidgets('the day lists it and opens it', (tester) async {
      OpenHouse? opened;
      await _pump(tester, _agenda(onOpen: (o) => opened = o));

      expect(find.text('Open house'), findsOneWidget);
      expect(find.text('12:00–15:00 · 2 visitors'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('calendar-open-house-1')));
      expect(opened?.id, 1);
    });
  });

  group('in the client', () {
    testWidgets('a visit reads as one, with the listing it was at',
        (tester) async {
      await _pump(
          tester,
          _page(ClientHistoryCard(
            activities: [
              ClientActivity(
                id: 1,
                clientId: 21,
                note: 'Wants a quiet floor',
                occurredAt: _now,
                authorName: 'Aigul Bekova',
                openHouseId: 1,
                properties: const [
                  ActivityProperty(id: 7, title: 'Severny Residence')
                ],
              ),
            ],
            onLog: () {},
            onRetry: () {},
            onDelete: (_) {},
            canDelete: (_) => false,
          )));

      expect(find.text('Open house visit'), findsOneWidget);
      expect(find.text('Severny Residence'), findsOneWidget);
      expect(find.textContaining('sent'), findsNothing,
          reason: 'nothing went out; the listing is where it happened');
    });

    testWidgets('a buyer who came through the door says so', (tester) async {
      await _pump(tester,
          _page(const ClientSourceBadge(source: ClientSource.openHouse)));
      expect(find.text('From an open house'), findsOneWidget);
    });

    test('the server names where a client came from', () {
      final client = ClientResponse.fromJson(
          const {'id': 1, 'fullName': 'A', 'source': 'OPEN_HOUSE'});
      expect(client.source, ClientSource.openHouse);
    });
  });

  test('the sheet and the listing\'s open houses can be read offline', () {
    for (final path in [
      '/open-houses/1',
      '/open-houses?from=2026-10-01T00:00:00.000&to=2026-11-01T00:00:00.000',
      '/properties/7/open-houses',
    ]) {
      expect(OfflineCache.isCacheable('GET', path), isTrue, reason: path);
    }
    expect(
        OfflineCache.isCacheable('POST', '/open-houses/1/visitors'), isFalse);
  });

  test('a visitor whose interest the app does not know reads as unanswered',
      () {
    final v = OpenHouseVisitor.fromJson(const {
      'id': 1,
      'openHouseId': 2,
      'fullName': 'A',
      'phone': '+7',
      'interest': 'MAYBE_LATER',
    });
    expect(v.interest, isNull);
    final o = OpenHouse.fromJson(const {
      'id': 2,
      'propertyId': 7,
      'startsAt': '2026-10-04T12:00:00',
      'endsAt': '2026-10-04T15:00:00',
      'visitorCount': 4,
      'newClientCount': 3,
      'interestedCount': 2,
    });
    expect(o.visitors, isEmpty, reason: 'lists leave the sheet out');
    expect(o.isOn(_now), isTrue);
    expect(o.isOver(DateTime(2026, 10, 4, 15)), isTrue);
  });
}
