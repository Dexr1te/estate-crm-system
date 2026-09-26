import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/imports/presentation/screens/import_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _file =
    PickedFile(name: 'agency-book.csv', path: '/tmp/book.csv', size: 4096);

const _clientTargets = [
  ImportTarget(field: 'fullName', required: true),
  ImportTarget(field: 'phone'),
  ImportTarget(field: 'email'),
  ImportTarget(field: 'type'),
  ImportTarget(field: 'budgetMax'),
];

/// A sheet whose second column was not recognised: until it is mapped to the
/// phone, most rows lack one.
ImportPreview _preview(ImportKind kind, List<String?>? mapping) {
  final mapped = mapping ?? ['fullName', null, 'email'];
  final phoneMapped = mapped.contains('phone');
  final invalid = phoneMapped ? 3 : 45;
  return ImportPreview(
    kind: kind,
    headers: const [
      'ФИО',
      'Контакт клиента с очень длинным названием',
      'Email'
    ],
    mapping: mapped,
    targets: _clientTargets,
    totalRows: 50,
    validRows: 50 - invalid - 2,
    invalidRows: invalid,
    duplicateRows: 2,
    problems: [
      for (var i = 0; i < invalid; i++)
        ImportRowResult(
          row: i + 2,
          status: ImportRowStatus.invalid,
          errors: const {'phone': 'INVALID_PHONE', 'type': 'UNKNOWN_VALUE'},
          values: {'fullName': 'Клиент номер ${i + 1} с длинной фамилией'},
        ),
      const ImportRowResult(
        row: 60,
        status: ImportRowStatus.duplicate,
        values: {'fullName': 'Бекова Айгерим'},
        duplicate: ImportDuplicate(
            source: ImportDuplicateSource.agency,
            clientId: 7,
            clientName: 'Aigerim Bekova'),
      ),
      const ImportRowResult(
        row: 61,
        status: ImportRowStatus.duplicate,
        duplicate: ImportDuplicate(source: ImportDuplicateSource.file, row: 3),
      ),
    ],
  );
}

late FakeImportsRepository _repo;

void _setUp() {
  _repo = FakeImportsRepository(
    onPreview: _preview,
    result: const ImportResult(
        kind: ImportKind.clients,
        totalRows: 50,
        created: 45,
        skippedDuplicates: 2,
        invalid: 3),
  );
  Injector.importsRepository = _repo;
  Injector.fileGateway = FakeFileGateway(file: _file);
  Injector.shareGateway = FakeShareGateway();
  Injector.agentsRepository = const FakeAgentsRepository([
    AgentOption(id: 12, fullName: 'Timur Aliev', email: 'timur@almaty.kz'),
  ]);
}

Future<void> _pump(WidgetTester tester,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en'),
    ClientsBloc? clients}) async {
  final screen = clients == null
      ? const ImportScreen()
      : BlocProvider.value(value: clients, child: const ImportScreen());
  await expectNoOverflow(tester, screen,
      size: size, brightness: brightness, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
}

Future<void> _openPreview(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('import-pick-clients')));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(_setUp);

  testWidgets('pick, check, fix a column, import, see what happened',
      (tester) async {
    final clients = ClientsBloc(FakeClientsRepository());
    addTearDown(clients.close);
    await _pump(tester, clients: clients);

    await _openPreview(tester);
    expect(_repo.previews, [null], reason: 'the first reading suggests');
    expect(find.text('agency-book.csv'), findsOneWidget);
    expect(find.text('50 rows in the file'), findsOneWidget);
    expect(find.text('45'), findsWidgets);
    expect(find.text('Choose a column for Phone'), findsNothing);

    // Only the first page of problem rows is built.
    expect(find.byKey(const ValueKey('import-problem-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('import-problem-22')), findsNothing);
    await _tapVisible(tester, find.byKey(const ValueKey('import-show-more')));
    expect(find.byKey(const ValueKey('import-problem-22')), findsOneWidget);

    // The unrecognised column is mapped to the phone, and the file re-read.
    await _tapVisible(tester, find.byKey(const ValueKey('import-column-1')));
    await tester.tap(find.text('Phone').last);
    await tester.pumpAndSettle();
    expect(_repo.previews.last, ['fullName', 'phone', 'email']);
    expect(find.byKey(const ValueKey('import-problem-60')), findsOneWidget);
    expect(find.text('Already in the agency: Aigerim Bekova'), findsOneWidget);
    expect(find.text('Same as row 3'), findsOneWidget);

    // Rows go to a colleague, duplicates too.
    await _tapVisible(
        tester, find.byKey(const ValueKey('import-skip-duplicates')));
    await _tapVisible(tester, find.byKey(const ValueKey('import-assignee')));
    await tester.tap(find.text('Timur Aliev'));
    await tester.pumpAndSettle();
    expect(find.text('Import 47 rows'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const ValueKey('import-commit')));
    final commit = _repo.commits.single;
    expect(commit.mapping, ['fullName', 'phone', 'email']);
    expect(commit.skipDuplicates, isFalse);
    expect(commit.assignToAgentId, 12);

    expect(find.text('Import finished'), findsOneWidget);
    expect(find.byKey(const ValueKey('import-created')), findsOneWidget);
    expect(find.text('Open clients'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(clients.state, isA<ClientsLoaded>(),
        reason: 'the clients list is refreshed once rows went in');
  });

  testWidgets('a required field nobody fills keeps the import shut',
      (tester) async {
    _repo.onPreview =
        (kind, mapping) => _preview(kind, mapping ?? [null, null, 'email']);
    await _pump(tester);
    await _openPreview(tester);
    expect(find.text('Choose a column for Full name'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const ValueKey('import-commit')));
    expect(_repo.commits, isEmpty);
  });

  testWidgets('a file that is not a CSV or is too big never leaves the phone',
      (tester) async {
    Injector.fileGateway = FakeFileGateway(
        file: const PickedFile(name: 'book.xlsx', path: '/tmp/b', size: 10));
    await _pump(tester);
    await _openPreview(tester);
    expect(find.text('Choose a .csv file. In Excel: File, Save as, CSV.'),
        findsOneWidget);

    Injector.fileGateway = FakeFileGateway(
        file: const PickedFile(
            name: 'book.csv', path: '/tmp/b', size: maxImportBytes + 1));
    await _openPreview(tester);
    expect(find.text('The file is larger than 5 MB. Split it into parts.'),
        findsOneWidget);
    expect(_repo.previews, isEmpty);
  });

  testWidgets('the template is shared as a CSV in the screen language',
      (tester) async {
    final share = FakeShareGateway();
    Injector.shareGateway = share;
    await _pump(tester, locale: const Locale('ru'));
    await _tapVisible(
        tester, find.byKey(const ValueKey('import-template-properties')));
    expect(_repo.templates, ['properties/ru']);
    expect(share.sharedFile?.fileName, 'properties-template.csv');
    expect(share.sharedFile?.mimeType, 'text/csv');
  });

  group('who gets in', () {
    String? redirect(Role role) => resolveRedirect(
          location: '/import',
          sessionResolved: true,
          authenticated: true,
          role: role,
          hasTeam: true,
        );

    test('an agent is sent away; managers and admins are let in', () {
      expect(redirect(Role.AGENT), '/dashboard');
      expect(redirect(Role.MANAGER), isNull);
      expect(redirect(Role.ADMIN), isNull);
    });
  });

  for (final locale in kAcceptanceLocales) {
    forEachAcceptanceCase('import start ${locale.languageCode}',
        (tester, size, brightness, scale) async {
      await _pump(tester,
          size: size, brightness: brightness, scale: scale, locale: locale);
      expect(find.byKey(const ValueKey('import-kind-clients')), findsOneWidget);
    });

    forEachAcceptanceCase('import preview ${locale.languageCode}',
        (tester, size, brightness, scale) async {
      await _pump(tester,
          size: size, brightness: brightness, scale: scale, locale: locale);
      await _openPreview(tester);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('import-summary')), findsOneWidget);
    });

    forEachAcceptanceCase('import result ${locale.languageCode}',
        (tester, size, brightness, scale) async {
      await _pump(tester,
          size: size, brightness: brightness, scale: scale, locale: locale);
      await _openPreview(tester);
      await _tapVisible(tester, find.byKey(const ValueKey('import-commit')));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('import-created')), findsOneWidget);
    });
  }
}
