import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/documents/presentation/widgets/deal_documents_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The agent looking at the screen. Owns the first document and not the second,
/// which is what decides where a remove button appears.
const _me = AuthResponse(
  userId: 5,
  fullName: 'Maria Kim-Doroshenko',
  email: 'maria@estatecrm.kz',
  role: Role.AGENT,
);

const _deal = DealResponse(
  id: 1,
  title: 'Severny Residence, apartment 84',
  status: DealStatus.NEGOTIATION,
  clientId: 1,
  clientName: 'Irina Alexandrovna Sokolova',
  agentId: 5,
  agentName: 'Maria Kim-Doroshenko',
  dealPrice: 12300000,
);

final _documents = [
  DocumentResponse(
    id: 1,
    fileName: 'Договор купли-продажи №14.pdf',
    fileType: 'pdf',
    fileSize: 1887436,
    dealId: 1,
    uploadedById: 5,
    uploadedByName: 'Maria Kim-Doroshenko',
    uploadedAt: DateTime(2026, 7, 18, 9, 12),
  ),
  DocumentResponse(
    id: 2,
    fileName: 'floor-plan-apartment-84.png',
    fileType: 'png',
    fileSize: 240000,
    dealId: 1,
    uploadedById: 9,
    uploadedByName: 'Нурлан Беков',
    uploadedAt: DateTime(2026, 7, 19, 14, 40),
  ),
];

late FakeDocumentsRepository _repo;
late FakeFileGateway _gateway;

void _installFakes({
  List<DocumentResponse> documents = const [],
  PickedFile? picks,
  FileOpenOutcome opens = FileOpenOutcome.opened,
}) {
  _repo = FakeDocumentsRepository(documents);
  _gateway = FakeFileGateway(file: picks, outcome: opens);
  Injector.dealsRepository = FakeDealsRepository(const [_deal]);
  Injector.documentsRepository = _repo;
  Injector.fileGateway = _gateway;
}

Widget _wrap() => MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                AuthBloc(FakeAuthRepository(user: _me))..add(AuthCheckEvent())),
        BlocProvider(create: (_) => DealsBloc(FakeDealsRepository(const []))),
      ],
      child: const DealDetailScreen(id: 1),
    );

/// Pumps the deal screen at a size the whole card fits on, and settles the two
/// loads it starts — the deal itself and its documents.
Future<void> _openDeal(WidgetTester tester) async {
  await expectNoOverflow(
    tester,
    _wrap(),
    size: const Size(430, 932),
    brightness: Brightness.light,
    textScale: 1.0,
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => _installFakes(documents: _documents));

  forEachAcceptanceCase('deal documents',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('deal documents render in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.3,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the card lists what is attached, with its size', (tester) async {
    await _openDeal(tester);

    expect(find.text('Договор купли-продажи №14.pdf'), findsOneWidget);
    expect(find.text('floor-plan-apartment-84.png'), findsOneWidget);
    expect(find.textContaining('1.8 MB'), findsOneWidget);
    expect(find.textContaining('234 KB'), findsOneWidget);
  });

  testWidgets('an empty deal says so and still offers to attach',
      (tester) async {
    _installFakes();
    await _openDeal(tester);

    expect(find.text('No files attached to this deal yet'), findsOneWidget);
    expect(find.text('Attach file'), findsOneWidget);
  });

  testWidgets('a chosen file is uploaded and joins the list', (tester) async {
    _installFakes(
      picks: const PickedFile(
          name: 'passport-scan.jpg',
          path: '/tmp/passport-scan.jpg',
          size: 90000),
    );
    await _openDeal(tester);

    await _tap(tester, find.text('Attach file'));

    expect(_repo.uploaded?.name, 'passport-scan.jpg');
    expect(find.text('passport-scan.jpg'), findsOneWidget);
    expect(find.text('Document attached'), findsOneWidget);
  });

  testWidgets('backing out of the file browser attaches nothing',
      (tester) async {
    _installFakes();
    await _openDeal(tester);

    await _tap(tester, find.text('Attach file'));

    expect(_repo.uploaded, isNull);
    expect(find.text('Document attached'), findsNothing);
  });

  testWidgets('a file over the limit never leaves the phone', (tester) async {
    _installFakes(
      picks: const PickedFile(
          name: 'walkthrough.zip',
          path: '/tmp/walkthrough.zip',
          size: 40 * 1024 * 1024),
    );
    await _openDeal(tester);

    await _tap(tester, find.text('Attach file'));

    expect(_repo.uploaded, isNull);
    expect(find.text('Files larger than 20 MB cannot be attached'),
        findsOneWidget);
  });

  testWidgets('tapping a document downloads it and hands it to the phone',
      (tester) async {
    await _openDeal(tester);

    await _tap(tester, find.text('Договор купли-продажи №14.pdf'));

    expect(_repo.downloadedId, 1);
    expect(_gateway.openedName, 'Договор купли-продажи №14.pdf');
    expect(_gateway.openedBytes, _repo.bytes);
  });

  testWidgets('a phone with nothing that opens it says so', (tester) async {
    _installFakes(documents: _documents, opens: FileOpenOutcome.noApp);
    await _openDeal(tester);

    await _tap(tester, find.text('floor-plan-apartment-84.png'));

    expect(
        find.text('No app on this phone can open this file'), findsOneWidget);
  });

  testWidgets('only what you uploaded yourself offers a remove button',
      (tester) async {
    await _openDeal(tester);

    // Two documents, one of them somebody else's: exactly one remove button.
    expect(
        find.descendant(
          of: find.byType(DocumentRow),
          matching: find.byIcon(Icons.delete_outline_rounded),
        ),
        findsOneWidget);
  });

  testWidgets('removing a document asks first, then drops the row',
      (tester) async {
    await _openDeal(tester);

    await _tap(
      tester,
      find.descendant(
        of: find.byType(DocumentRow),
        matching: find.byIcon(Icons.delete_outline_rounded),
      ),
    );

    expect(find.text('Remove document'), findsOneWidget);
    expect(_repo.deletedId, isNull,
        reason: 'nothing goes until it is confirmed');

    await _tap(tester, find.text('Delete'));

    expect(_repo.deletedId, 1);
    expect(find.text('Договор купли-продажи №14.pdf'), findsNothing);
    expect(find.text('Document removed'), findsOneWidget);
  });
}
