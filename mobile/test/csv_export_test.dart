import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';
import 'package:real_estate_crm/features/exports/presentation/widgets/export_console_card.dart';
import 'package:real_estate_crm/features/exports/presentation/widgets/export_sheet.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);
const _admin =
    AuthResponse(userId: 1, fullName: 'Admin', role: Role.ADMIN, teamId: 1);
const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);

late FakeExportsRepository _exports;
late FakeShareGateway _share;

Widget _signedIn(AuthResponse user, Widget child,
        {List<BlocProvider> extra = const []}) =>
    MultiBlocProvider(
      key: UniqueKey(),
      providers: [
        BlocProvider(
            create: (_) => AuthBloc(FakeAuthRepository(user: user))
              ..add(AuthCheckEvent())),
        ...extra,
      ],
      child: child,
    );

Widget _clients(AuthResponse user) =>
    _signedIn(user, const ClientsScreen(), extra: [
      BlocProvider<ClientsBloc>(
          create: (_) => ClientsBloc(FakeClientsRepository(clients: const [])))
    ]);

Widget _properties(AuthResponse user) =>
    _signedIn(user, const PropertiesScreen(), extra: [
      BlocProvider<PropertiesBloc>(
          create: (_) => PropertiesBloc(FakePropertiesRepository(const [])))
    ]);

Widget _deals(AuthResponse user, {DealStatus? status}) =>
    _signedIn(user, DealsScreen(initialStatus: status), extra: [
      BlocProvider<DealsBloc>(
          create: (_) => DealsBloc(FakeDealsRepository(const [])))
    ]);

Future<void> _pump(WidgetTester tester, Widget screen,
    {Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, screen,
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: locale);
  await tester.pumpAndSettle();
}

FilterPill _pill(WidgetTester tester, ExportDelimiter d) => tester
    .widget<FilterPill>(find.byKey(ValueKey('export-delimiter-${d.param}')));

Future<void> _confirm(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const ValueKey('export-confirm')));
  await tester.tap(find.byKey(const ValueKey('export-confirm')));
  await tester.pumpAndSettle();
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    _exports = FakeExportsRepository();
    _share = FakeShareGateway();
    Injector.exportsRepository = _exports;
    Injector.shareGateway = _share;
  });

  group('who is offered the export', () {
    testWidgets('an agent sees no export on any list', (tester) async {
      await _pump(tester, _clients(_agent));
      expect(find.byKey(const ValueKey('export-clients')), findsNothing);
      await _pump(tester, _properties(_agent));
      expect(find.byKey(const ValueKey('export-properties')), findsNothing);
      await _pump(tester, _deals(_agent));
      expect(find.byKey(const ValueKey('export-deals')), findsNothing);
    });

    testWidgets('a manager and an admin see it on every list', (tester) async {
      for (final user in [_manager, _admin]) {
        await _pump(tester, _clients(user));
        expect(find.byKey(const ValueKey('export-clients')), findsOneWidget);
        await _pump(tester, _properties(user));
        expect(find.byKey(const ValueKey('export-properties')), findsOneWidget);
        await _pump(tester, _deals(user));
        expect(find.byKey(const ValueKey('export-deals')), findsOneWidget);
      }
    });

    testWidgets('the console card is a manager\'s only', (tester) async {
      await _pump(
          tester, _signedIn(_agent, const Scaffold(body: ExportConsoleCard())));
      expect(find.byKey(const ValueKey('export-console')), findsNothing);
      await _pump(tester,
          _signedIn(_manager, const Scaffold(body: ExportConsoleCard())));
      expect(find.byKey(const ValueKey('export-console')), findsOneWidget);
    });
  });

  testWidgets('clients: the list\'s filters go out, and the file is shared',
      (tester) async {
    await _pump(tester, _clients(_manager));
    await tester.tap(find.text(en.clientsFilterSellers));
    await tester.enterText(find.byType(TextField).first, 'Timur');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('export-clients')));
    await tester.pumpAndSettle();
    expect(find.text(en.exportTitleClients), findsOneWidget);
    expect(find.byKey(const ValueKey('export-personal-data')), findsOneWidget);
    expect(find.text(en.exportFiltersNote), findsOneWidget);
    expect(_pill(tester, ExportDelimiter.comma).selected, isTrue);
    await _confirm(tester);

    final request = _exports.requests.single;
    expect(request.kind, ExportKind.clients);
    expect(
        request.filters, const ExportFilters(type: 'SELLER', search: 'Timur'));
    expect(request.lang, 'en');
    expect(request.delimiter, ExportDelimiter.comma);
    expect(_share.sharedFile!.fileName, 'clients-2026-09-28.csv');
    expect(_share.sharedFile!.mimeType, 'text/csv');
    expect(_share.sharedFile!.bytes, [0xEF, 0xBB, 0xBF, 0x41]);
  });

  testWidgets('new leads export as public-link clients of the last week',
      (tester) async {
    await _pump(tester, _clients(_manager));
    await tester
        .ensureVisible(find.byKey(const ValueKey('clients-filter-leads')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('clients-filter-leads')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('export-clients')));
    await tester.pumpAndSettle();
    await _confirm(tester);
    final filters = _exports.requests.single.filters;
    expect(filters.source, 'PUBLIC_LINK');
    expect(filters.createdFrom, isNotNull);
  });

  testWidgets('Russian defaults to semicolons, and comma can be chosen',
      (tester) async {
    await _pump(tester, _properties(_manager), locale: const Locale('ru'));
    await tester.tap(find.byKey(const ValueKey('export-properties')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('export-personal-data')), findsNothing);
    expect(_pill(tester, ExportDelimiter.semicolon).selected, isTrue);
    await tester.tap(find.byKey(const ValueKey('export-delimiter-comma')));
    await tester.pump();
    expect(_pill(tester, ExportDelimiter.comma).selected, isTrue);
    await _confirm(tester);
    final request = _exports.requests.single;
    expect(request.kind, ExportKind.properties);
    expect(request.lang, 'ru');
    expect(request.delimiter, ExportDelimiter.comma);
    expect(request.filters, ExportFilters.none);
  });

  testWidgets('deals: the status shown is the status exported', (tester) async {
    await _pump(tester, _deals(_manager, status: DealStatus.NEGOTIATION));
    await tester.tap(find.byKey(const ValueKey('export-deals')));
    await tester.pumpAndSettle();
    await _confirm(tester);
    expect(_exports.requests.single.filters,
        const ExportFilters(status: 'NEGOTIATION'));
  });

  testWidgets('dismissing the sheet downloads nothing', (tester) async {
    await _pump(tester, _clients(_manager));
    await tester.tap(find.byKey(const ValueKey('export-clients')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 60));
    await tester.pumpAndSettle();
    expect(_exports.requests, isEmpty);
    expect(_share.calls, 0);
  });

  testWidgets('the console exports a whole kind, unfiltered', (tester) async {
    await _pump(
        tester, _signedIn(_manager, const Scaffold(body: ExportConsoleCard())));
    await tester.tap(find.byKey(const ValueKey('export-console-deals')));
    await tester.pumpAndSettle();
    expect(find.text(en.exportTitleDeals), findsOneWidget);
    expect(find.text(en.exportAllNote), findsOneWidget);
    await _confirm(tester);
    expect(_exports.requests.single.kind, ExportKind.deals);
    expect(_exports.requests.single.filters, ExportFilters.none);
  });

  group('when it goes wrong', () {
    Future<void> run(WidgetTester tester) async {
      await _pump(tester, _clients(_manager));
      await tester.tap(find.byKey(const ValueKey('export-clients')));
      await tester.pumpAndSettle();
      await _confirm(tester);
    }

    testWidgets('too many rows says to narrow the filters', (tester) async {
      final options = RequestOptions(path: '/export/clients');
      _exports.failure = DioException(
        requestOptions: options,
        response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'code': 'EXPORT_TOO_MANY_ROWS', 'message': 'too many'}),
        type: DioExceptionType.badResponse,
      );
      await run(tester);
      expect(find.text(en.exportTooMany), findsOneWidget);
      expect(_share.calls, 0);
    });

    testWidgets('any other failure says it failed', (tester) async {
      _exports.failure = Exception('offline');
      await run(tester);
      expect(find.text(en.exportFailed), findsOneWidget);
    });

    testWidgets('a share sheet that fails says so', (tester) async {
      _share.outcome = ShareOutcome.failed;
      await run(tester);
      expect(find.text(en.exportFailed), findsOneWidget);
    });
  });

  test('the server\'s file name is read from Content-Disposition', () {
    expect(
        ExportFile.fileNameFrom(
            'attachment; filename="deals-2026-09-28.csv"; '
                "filename*=UTF-8''deals-2026-09-28.csv",
            'x.csv'),
        'deals-2026-09-28.csv');
    expect(ExportFile.fileNameFrom('attachment; filename="a.csv"', 'x.csv'),
        'a.csv');
    expect(ExportFile.fileNameFrom(null, 'x.csv'), 'x.csv');
  });

  forEachAcceptanceCase('the export sheet',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Builder(
              builder: (context) => AppSheetShell(
                title: AppLocalizations.of(context).exportTitleClients,
                child: ExportOptionsForm(
                    kind: ExportKind.clients,
                    filters: const ExportFilters(type: 'BUYER'),
                    onConfirm: (_) {}),
              ),
            ),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
    }
  });
}
