import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/data/datasources/client_dates_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/domain/client_birthday.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_dates_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_date_row.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/dates_this_week_card.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'client_dates_fixtures.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// Birthdays and purchase anniversaries: picked on the form, shown on the
/// card, listed when they come up with a greeting a tap away, on the
/// dashboard for the week, and told on the day.

const _birthdayTemplate = MessageTemplate(
  id: 6,
  title: 'Birthday greeting',
  body: 'Happy birthday, {client}! {agent}',
);

const _intro = MessageTemplate(
  id: 1,
  title: 'Introduction',
  body: 'Hello, {client}! This is {agent}.',
);

const _manager = AuthResponse(
    userId: 9, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

late FakeClientDatesRepository _dates;
late FakeClientsRepository _clients;
late FakeMessageTemplatesRepository _templates;
late List<Uri> _opened;

void _install(List<UpcomingClientDate> dates) {
  _dates = FakeClientDatesRepository(dates);
  Injector.clientDatesRepository = _dates;
  _clients = FakeClientsRepository();
  Injector.clientsRepository = _clients;
  _templates =
      FakeMessageTemplatesRepository(const [_intro, _birthdayTemplate]);
  Injector.messageTemplatesRepository = _templates;
  _opened = [];
  ContactActions.opener = (uri, _) async {
    _opened.add(uri);
    return true;
  };
  addTearDown(ContactActions.resetOpener);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget _card(ClientDatesBloc bloc, {VoidCallback? onSeeAll}) => Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocProvider.value(
          value: bloc,
          child: DatesThisWeekCard(onSeeAll: onSeeAll ?? () {}),
        ),
      ),
    );

ClientDatesBloc _weekBloc() {
  final bloc = ClientDatesBloc(_dates, days: 7)..add(ClientDatesLoadEvent());
  addTearDown(bloc.close);
  return bloc;
}

void main() {
  setUp(() {
    AppClock.freeze(kDatesNow);
    addTearDown(AppClock.reset);
  });

  group('the birthday as a value', () {
    test('reads and writes the API forms, and nothing else', () {
      final full = ClientBirthday.parse('1990-05-14')!;
      expect((full.month, full.day, full.year), (5, 14, 1990));
      expect(full.toApi(), '1990-05-14');
      final noYear = ClientBirthday.parse('--02-29')!;
      expect(noYear.year, isNull);
      expect(noYear.toApi(), '--02-29');
      expect(noYear.asDate, DateTime(2000, 2, 29));
      expect(full.withoutYear().toApi(), '--05-14');
      expect(ClientBirthday.parse(null), isNull);
      expect(ClientBirthday.parse(''), isNull);
      expect(ClientBirthday.parse('14.05.1990'), isNull);
    });

    test('the age is counted to the birthday, not the new year', () {
      const b = ClientBirthday(month: 10, day: 2, year: 1990);
      expect(b.ageOn(DateTime(2026, 10, 1)), 35);
      expect(b.ageOn(DateTime(2026, 10, 2)), 36);
      expect(b.withoutYear().ageOn(DateTime(2026, 10, 2)), isNull);
    });

    test('labels in the reader\'s language', () async {
      await initializeDateFormatting();
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      expect(
          clientBirthdayLabel(
              const ClientBirthday(month: 5, day: 14, year: 1990), 'en'),
          'May 14, 1990');
      expect(clientBirthdayLabel(const ClientBirthday(month: 5, day: 14), 'en'),
          'May 14');
      expect(clientDateWhenLabel(en, 0), 'Today');
      expect(clientDateWhenLabel(en, 1), 'Tomorrow');
      expect(clientDateWhenLabel(en, 5), 'In 5 days');
      expect(clientDateWhenLabel(ru, 2), 'Через 2 дня');
      expect(clientDateWhenLabel(ru, 5), 'Через 5 дней');
      expect(clientDateWhatLabel(en, birthdayIn(0)), 'Birthday, turns 36');
      expect(clientDateWhatLabel(en, birthdayIn(0, years: null)), 'Birthday');
      expect(clientDateWhatLabel(en, anniversaryIn(0, years: 1)),
          '1 year since the purchase');
      expect(clientDateWhatLabel(ru, anniversaryIn(0, years: 5)),
          '5 лет с покупки');
    });

    test('the default birthday greeting is found in every language', () {
      for (final title in [
        'Birthday greeting',
        'Поздравление с днём рождения',
        'Туған күн құттықтауы',
      ]) {
        expect(isBirthdayGreeting(MessageTemplate(id: 1, title: title)), isTrue,
            reason: title);
      }
      expect(isBirthdayGreeting(_intro), isFalse);
    });

    test('the phone\'s today is what is asked for', () {
      expect(ClientDatesRemoteDataSource.isoDay(DateTime(2026, 3, 7, 23, 59)),
          '2026-03-07');
    });
  });

  group('dates coming up', () {
    testWidgets('today first, each saying what and when', (tester) async {
      _install([
        birthdayIn(0),
        anniversaryIn(3),
        birthdayIn(10, clientId: 3, name: 'Dana Omarova', years: null),
      ]);
      await _pump(tester, const ClientDatesScreen());

      expect(find.byType(ClientDateRow), findsNWidgets(3));
      expect(find.text('Today · Sep 30'), findsOneWidget);
      expect(find.text('Birthday, turns 36'), findsOneWidget);
      expect(find.text('In 3 days · Oct 3'), findsOneWidget);
      expect(find.text('3 years since the purchase'), findsOneWidget);
      expect(find.text('Dostyk 5, apt 12'), findsOneWidget);
      expect(find.text('In 10 days · Oct 10'), findsOneWidget);
      expect(_dates.queries.single.$1, kDatesNow);
      expect(_dates.queries.single.$2, 14);
    });

    testWidgets('nothing coming up is an empty state', (tester) async {
      _install(const []);
      await _pump(tester, const ClientDatesScreen());
      expect(find.text('No dates in the next two weeks'), findsOneWidget);
    });

    testWidgets('a failure says so and can be retried', (tester) async {
      _install([birthdayIn(0)]);
      _dates.readError = Exception('down');
      await _pump(tester, const ClientDatesScreen());
      expect(find.text("Couldn't load the dates coming up"), findsOneWidget);

      _dates.readError = null;
      await _tap(tester, find.text('Retry'));
      expect(find.byType(ClientDateRow), findsOneWidget);
    });

    testWidgets('greeting a birthday starts from the birthday template',
        (tester) async {
      _install([birthdayIn(0)]);
      await _pump(tester, const ClientDatesScreen());

      await _tap(
          tester, find.byKey(const ValueKey('client-date-greet-birthday-1-0')));
      final field = tester.widget<EditableText>(find.descendant(
          of: find.byKey(const Key('compose-text')),
          matching: find.byType(EditableText)));
      expect(
          field.controller.text, 'Happy birthday, Aigerim Bekova! Timur Aliev');

      await _tap(tester, find.byKey(const Key('compose-sms')));
      expect(_opened.single.scheme, 'sms');
      expect(_clients.logCalls.single.type, ActivityType.MESSAGE);
      expect(_clients.logCalls.single.note,
          'Happy birthday, Aigerim Bekova! Timur Aliev');
      expect(find.text("Saved to the client's history"), findsOneWidget);
    });

    testWidgets('an anniversary greeting is written by hand', (tester) async {
      _install([anniversaryIn(0)]);
      await _pump(tester, const ClientDatesScreen());

      await _tap(
          tester,
          find.byKey(
              const ValueKey('client-date-greet-purchaseAnniversary-2-42')));
      final field = tester.widget<EditableText>(find.descendant(
          of: find.byKey(const Key('compose-text')),
          matching: find.byType(EditableText)));
      expect(field.controller.text, isEmpty);
    });

    testWidgets('no phone, no sheet', (tester) async {
      _install([birthdayIn(0, phone: null)]);
      await _pump(tester, const ClientDatesScreen());

      await _tap(
          tester, find.byKey(const ValueKey('client-date-greet-birthday-1-0')));
      expect(find.byKey(const Key('compose-text')), findsNothing);
      expect(find.text('No phone number on file'), findsOneWidget);
    });

    testWidgets('a call goes to the client\'s number', (tester) async {
      _install([birthdayIn(0)]);
      await _pump(tester, const ClientDatesScreen());

      await _tap(
          tester, find.byKey(const ValueKey('client-date-call-birthday-1-0')));
      expect(_opened.single.scheme, 'tel');
    });
  });

  group('the dashboard card', () {
    testWidgets('is not there when nothing falls this week', (tester) async {
      _install(const []);
      await _pump(tester, _card(_weekBloc()));
      expect(find.byKey(const ValueKey('dates-card')), findsNothing);
      expect(_dates.queries.single.$2, 7);
    });

    testWidgets('shows the first three, how many in all, and see all',
        (tester) async {
      _install([
        birthdayIn(0),
        anniversaryIn(1),
        birthdayIn(2, clientId: 3, name: 'Dana Omarova'),
        birthdayIn(4, clientId: 4, name: 'Erlan Sadykov'),
        birthdayIn(6, clientId: 5, name: 'Farida Ismail'),
      ]);
      var seeAll = 0;
      await _pump(tester, _card(_weekBloc(), onSeeAll: () => seeAll++));

      expect(find.byType(ClientDateRow), findsNWidgets(kDatesPreview));
      expect(find.text('5 this week'), findsOneWidget);
      expect(find.text('Erlan Sadykov'), findsNothing);
      await _tap(tester, find.byKey(const ValueKey('dates-see-all')));
      expect(seeAll, 1);
    });

    testWidgets('a failure stays inside the card', (tester) async {
      _install([birthdayIn(0)]);
      _dates.readError = Exception('down');
      await _pump(tester, _card(_weekBloc()));
      expect(find.byKey(const ValueKey('dates-retry')), findsOneWidget);

      _dates.readError = null;
      await _tap(tester, find.byKey(const ValueKey('dates-retry')));
      expect(find.byType(ClientDateRow), findsOneWidget);
    });
  });

  group('the client', () {
    const withBirthday = ClientResponse(
      id: 4,
      fullName: 'Aigerim Bekova',
      phone: '+7 701 111 22 33',
      birthday: '1990-05-14',
    );

    Future<void> pumpForm(WidgetTester tester, ClientResponse client) async {
      _install(const []);
      _clients = FakeClientsRepository(clients: [client]);
      Injector.clientsRepository = _clients;
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final bloc = ClientsBloc(_clients);
      addTearDown(bloc.close);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider.value(value: bloc),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: '/clients/${client.id}/edit',
            routes: [
              GoRoute(
                  path: '/clients',
                  builder: (_, __) => const Scaffold(body: Text('list'))),
              GoRoute(
                  path: '/clients/:id/edit',
                  builder: (_, s) => ClientFormScreen(
                      clientId: int.parse(s.pathParameters['id']!))),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    Future<Map<String, dynamic>> save(WidgetTester tester) async {
      await _tap(tester, find.text('Update Client'));
      return _clients.updated.single.$2;
    }

    testWidgets('the form shows the birthday and can drop its year',
        (tester) async {
      await pumpForm(tester, withBirthday);
      expect(find.text('May 14, 1990'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('client-birthday-no-year')));
      expect(find.text('May 14'), findsOneWidget);
      expect(
          find.text('With the year unknown, only the day and month are kept.'),
          findsOneWidget);
      expect((await save(tester))['birthday'], '--05-14');
    });

    testWidgets('a day picked from the calendar is sent', (tester) async {
      await pumpForm(tester, withBirthday);
      await _tap(tester, find.byKey(const ValueKey('client-birthday')));
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('May 20, 1990'), findsOneWidget);
      expect((await save(tester))['birthday'], '1990-05-20');
    });

    testWidgets('taking the birthday off sends an empty one', (tester) async {
      await pumpForm(tester, withBirthday);
      await _tap(tester, find.byKey(const ValueKey('client-birthday-clear')));
      expect(find.text('Choose a date'), findsOneWidget);
      expect((await save(tester))['birthday'], '');
    });

    testWidgets('a client without a birthday saves without one',
        (tester) async {
      await pumpForm(tester, withBirthday.copyWith(birthday: null));
      expect(
          find.byKey(const ValueKey('client-birthday-no-year')), findsNothing);
      expect((await save(tester))['birthday'], '');
    });

    testWidgets('the card shows the birthday and the age', (tester) async {
      _install(const []);
      _clients = FakeClientsRepository(clients: const [withBirthday]);
      Injector.clientsRepository = _clients;
      final auth = AuthBloc(FakeAuthRepository(user: _manager))
        ..add(AuthCheckEvent());
      addTearDown(auth.close);
      await auth.stream.firstWhere((s) => s is AuthAuthenticated);
      await _pump(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: auth),
            BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
          ],
          child: const ClientDetailScreen(id: 4),
        ),
      );
      final row = find.byKey(const ValueKey('client-birthday-row'));
      await tester.ensureVisible(row);
      expect(
          find.descendant(
              of: row, matching: find.text('May 14, 1990 · 36 years old')),
          findsOneWidget);
    });
  });

  group('on the day', () {
    AppNotification note(NotificationType type, Map<String, dynamic> params) =>
        AppNotification(
            id: 1,
            type: type,
            targetId: 9,
            params: params,
            createdAt: kDatesNow);

    test('a birthday and an anniversary read as sentences and open the client',
        () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      final birthday = note(NotificationType.clientBirthday,
          {'clientName': 'Aigerim', 'years': 36});
      final anniversary = note(NotificationType.purchaseAnniversary,
          {'clientName': 'Bolat', 'years': 3, 'dealTitle': 'Flat on Dostyk'});

      expect(notificationCopy(en, birthday).title,
          "It's Aigerim's birthday today");
      expect(notificationCopy(en, birthday).detail, 'Birthday, turns 36');
      expect(
          notificationCopy(
              en,
              note(NotificationType.clientBirthday,
                  {'clientName': 'Aigerim'})).detail,
          isNull);
      expect(notificationCopy(en, anniversary).title,
          "3 years today since Bolat's purchase");
      expect(notificationCopy(en, anniversary).detail, 'Flat on Dostyk');
      expect(notificationCopy(ru, anniversary).title,
          'Сегодня 3 года с покупки клиента Bolat');
      expect(notificationTarget(birthday)!.location, '/clients/9');
      expect(notificationTarget(anniversary)!.location, '/clients/9');
    });
  });

  group('every size, theme and language', () {
    forEachAcceptanceCase('dates screen',
        (tester, size, brightness, scale) async {
      for (final locale in kAcceptanceLocales) {
        _install([
          birthdayIn(0, name: 'Aigerim Bekova-Nurlanovna Sadykova', years: 101),
          anniversaryIn(1,
              years: 12,
              propertyTitle:
                  'Residential complex Esentai City, block 4, apt 120'),
          birthdayIn(12, clientId: 3, years: null),
        ]);
        await expectNoOverflow(
          tester,
          ClientDatesScreen(key: ValueKey(locale)),
          size: size,
          brightness: brightness,
          textScale: scale,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'screen, ${locale.languageCode}');
      }
    });

    forEachAcceptanceCase('dates card',
        (tester, size, brightness, scale) async {
      for (final locale in kAcceptanceLocales) {
        _install([
          birthdayIn(0, name: 'Aigerim Bekova-Nurlanovna Sadykova'),
          anniversaryIn(1, years: 21),
          birthdayIn(2, clientId: 3),
          birthdayIn(5, clientId: 4),
        ]);
        final bloc = _weekBloc();
        await expectNoOverflow(
          tester,
          Scaffold(
            key: ValueKey(locale),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: BlocProvider.value(
                value: bloc,
                child: DatesThisWeekCard(onSeeAll: () {}),
              ),
            ),
          ),
          size: size,
          brightness: brightness,
          textScale: scale,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'card, ${locale.languageCode}');
        expect(find.byType(ClientDateRow), findsNWidgets(kDatesPreview));
      }
    });
  });
}
