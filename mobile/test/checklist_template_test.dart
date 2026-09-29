import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/checklist_template_bloc.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/checklist_template_event.dart';
import 'package:real_estate_crm/features/checklist/presentation/screens/checklist_template_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The manager's editor for what every new deal starts with: lines per
/// stage, added, renamed, marked required, dragged into order, removed — and
/// nothing leaves the phone until Save.

const _template = [
  ChecklistItem(
      id: 1,
      stage: ChecklistStage.LEAD,
      title: "Copy of the buyer's ID",
      required: true),
  ChecklistItem(
      id: 2,
      stage: ChecklistStage.LEAD,
      title: 'Bank pre-approval',
      position: 1),
  ChecklistItem(
      id: 3,
      stage: ChecklistStage.NEGOTIATION,
      title: 'Signed deposit agreement',
      required: true),
];

late FakeChecklistRepository _repo;

Future<void> _pump(WidgetTester tester,
    {Size size = const Size(390, 1400),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, const ChecklistTemplateScreen(),
      size: size, brightness: brightness, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
}

AppFilledButton _save(WidgetTester tester) =>
    tester.widget<AppFilledButton>(find.byKey(const Key('template-save')));

Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('template-save')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _repo = FakeChecklistRepository(template: List.of(_template));
    Injector.checklistRepository = _repo;
  });
  tearDown(() => Injector.checklistRepository = FakeChecklistRepository());

  testWidgets('the template reads by stage; Save waits for a change',
      (tester) async {
    await _pump(tester);
    expect(find.text("Copy of the buyer's ID"), findsOneWidget);
    expect(find.text('Signed deposit agreement'), findsOneWidget);
    expect(find.text('No items at this stage yet'), findsOneWidget,
        reason: 'Won has no lines');
    expect(_save(tester).onPressed, isNull);
  });

  testWidgets('add, rename, mark required, delete — then save all of it',
      (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('template-add-CLOSED_WON')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('checklist-line-title')), 'Signed sale contract');
    await tester.pump();
    await tester.tap(find.byKey(const Key('checklist-line-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('template-title-id-2')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('checklist-line-title')), 'Mortgage pre-approval');
    await tester.pump();
    await tester.tap(find.byKey(const Key('checklist-line-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('template-required-id-2')));
    await tester.tap(find.byKey(const ValueKey('template-delete-id-3')));
    await tester.pumpAndSettle();
    expect(_save(tester).onPressed, isNotNull);

    await _tapSave(tester);
    final saved = _repo.savedTemplates.single;
    expect(saved.map((l) => l.title), [
      "Copy of the buyer's ID",
      'Mortgage pre-approval',
      'Signed sale contract',
    ]);
    expect(saved.map((l) => l.required), [true, true, false]);
    expect(saved.last.stage, ChecklistStage.CLOSED_WON);
    expect(find.text('Checklist saved'), findsOneWidget);
    expect(_save(tester).onPressed, isNull);
  });

  testWidgets('a line is dragged into order by its handle', (tester) async {
    await _pump(tester);
    final handle = find.byKey(const ValueKey('template-handle-id-2'));
    final target =
        tester.getTopLeft(find.byKey(const ValueKey('template-handle-id-1')));
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 50));
    final start = tester.getCenter(handle);
    for (var i = 1; i <= 10; i++) {
      await gesture.moveTo(Offset.lerp(start, target, i / 10)!);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();

    await _tapSave(tester);
    expect(_repo.savedTemplates.single.map((l) => l.title).take(2),
        ['Bank pre-approval', "Copy of the buyer's ID"]);
  });

  test('reordering stays inside its stage', () async {
    final bloc = ChecklistTemplateBloc(_repo)
      ..add(ChecklistTemplateLoadEvent());
    await Future<void>.delayed(Duration.zero);
    bloc.add(ChecklistTemplateReorderEvent(ChecklistStage.LEAD, 0, 2));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.lines.map((l) => l.title), [
      'Bank pre-approval',
      "Copy of the buyer's ID",
      'Signed deposit agreement',
    ]);
    expect(bloc.state.dirty, isTrue);
    await bloc.close();
  });

  testWidgets('a failed save keeps the edits and says so', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('template-delete-id-1')));
    await tester.pumpAndSettle();
    _repo.writeError = Exception('offline');
    await _tapSave(tester);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Copy of the buyer's ID"), findsNothing);
    expect(_save(tester).onPressed, isNotNull);
  });

  forEachAcceptanceCase('the checklist template editor',
      (tester, size, brightness, scale) async {
    await _pump(tester, size: size, brightness: brightness, scale: scale);
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the editor and its sheet in ${locale.languageCode}',
        (tester) async {
      await _pump(tester,
          size: const Size(320, 568), scale: 1.5, locale: locale);
      await tester.tap(find.byKey(const ValueKey('template-title-id-1')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
