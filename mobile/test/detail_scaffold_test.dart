import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'responsive_harness.dart';

const _bottomSafe = 34.0;

Widget _page({
  required Size size,
  double keyboard = 0,
  double top = 47,
  Widget? action,
  int blocks = 20,
}) =>
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          padding:
              EdgeInsets.only(top: top, bottom: keyboard > 0 ? 0 : _bottomSafe),
          viewPadding: EdgeInsets.only(top: top, bottom: _bottomSafe),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: DetailScaffold(
          title: 'Long form',
          bottomAction: action,
          children: [
            for (var i = 0; i < blocks; i++)
              SizedBox(
                  key: ValueKey('block-$i'),
                  height: 90,
                  child: Text('Block $i')),
          ],
        ),
      ),
    );

Widget _actions(VoidCallback onSave) => Column(
      children: [
        AppFilledButton(label: 'Save', onPressed: onSave),
        const SizedBox(height: 9),
        AppGhostButton(label: 'Cancel', onPressed: () {}),
      ],
    );

void _view(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the primary action is on screen without scrolling a long form',
      (tester) async {
    const size = Size(390, 844);
    _view(tester, size);
    var saved = 0;
    await tester.pumpWidget(_page(size: size, action: _actions(() => saved++)));
    await tester.pumpAndSettle();

    final save = tester.getRect(find.widgetWithText(AppFilledButton, 'Save'));
    expect(save.top, greaterThan(0));
    expect(save.bottom, lessThanOrEqualTo(size.height - _bottomSafe));
    expect(find.byType(PinnedActionBar), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.text('Save')),
        findsNothing);

    await tester.tap(find.text('Save'));
    expect(saved, 1);

    final bar = tester.getRect(find.byKey(const ValueKey('pinned-action-bar')));
    expect(bar.bottom, size.height);
    expect(tester.getRect(find.text('Cancel')).bottom,
        lessThanOrEqualTo(size.height - _bottomSafe));
  });

  testWidgets('nothing on the page hides behind the pinned bar',
      (tester) async {
    const size = Size(390, 844);
    _view(tester, size);
    await tester.pumpWidget(_page(size: size, action: _actions(() {})));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byKey(const ValueKey('pinned-action-bar')));
    final last = tester.getRect(find.byKey(const ValueKey('block-19')));
    expect(last.bottom, lessThanOrEqualTo(bar.top));
    expect(tester.getRect(find.byType(SingleChildScrollView)).bottom,
        lessThanOrEqualTo(bar.top));
  });

  testWidgets('the bar shows a hairline only while the page runs under it',
      (tester) async {
    const size = Size(390, 844);
    _view(tester, size);
    Color edge() {
      final box = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey('pinned-action-bar')));
      return (box.decoration as BoxDecoration).border!.top.color;
    }

    await tester.pumpWidget(_page(size: size, action: _actions(() {})));
    await tester.pumpAndSettle();
    expect(edge(), AppTokens.light.border);

    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(edge(), AppTokens.light.background);

    await tester
        .pumpWidget(_page(size: size, action: _actions(() {}), blocks: 1));
    await tester.pumpAndSettle();
    expect(edge(), AppTokens.light.background);
  });

  testWidgets('the bar rises with the keyboard', (tester) async {
    const size = Size(390, 844);
    const keyboard = 300.0;
    _view(tester, size);
    await tester.pumpWidget(
        _page(size: size, keyboard: keyboard, action: _actions(() {})));
    await tester.pumpAndSettle();

    final cancel = tester.getRect(find.text('Cancel'));
    expect(cancel.bottom, lessThanOrEqualTo(size.height - keyboard));
    expect(cancel.bottom, greaterThan(size.height - keyboard - 40));
    expect(tester.getRect(find.byType(SingleChildScrollView)).bottom,
        lessThanOrEqualTo(tester.getRect(find.text('Save')).top));
  });

  testWidgets('with too little room left the action goes back in the page',
      (tester) async {
    const size = Size(320, 568);
    _view(tester, size);
    await tester.pumpWidget(
        _page(size: size, keyboard: 260, top: 20, action: _actions(() {})));
    await tester.pumpAndSettle();

    expect(find.byType(PinnedActionBar), findsNothing);
    expect(
        find.descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.text('Save')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a message shows above the pinned bar, not over it',
      (tester) async {
    const size = Size(390, 844);
    _view(tester, size);
    await tester.pumpWidget(_page(size: size, action: _actions(() {})));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(tester.element(find.text('Block 0')))
        .showSnackBar(const SnackBar(content: Text('Saved offline')));
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byKey(const ValueKey('pinned-action-bar')));
    expect(tester.getRect(find.byType(SnackBar)).bottom,
        lessThanOrEqualTo(bar.top));
  });

  testWidgets('a page without an action keeps its plain bottom padding',
      (tester) async {
    const size = Size(390, 844);
    _view(tester, size);
    await tester.pumpWidget(_page(size: size, blocks: 1));
    await tester.pumpAndSettle();
    expect(find.byType(PinnedActionBar), findsNothing);
  });

  testWidgets('the back button uses the platform glyph and a 44pt target',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: DetailAppBar(title: 'Client')),
    ));

    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);

    final tile = tester.getSize(find.byType(AppIconTile));
    expect(tile.width, greaterThanOrEqualTo(AppMetrics.minHitTarget));
    expect(tile.height, greaterThanOrEqualTo(AppMetrics.minHitTarget));
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android gets the Material arrow', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: DetailAppBar(title: 'Client')),
    ));
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'a three-button pinned bar fits at 320 @1.5 in '
          '${locale.languageCode} ${brightness.name}', (tester) async {
        await expectNoOverflow(
          tester,
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return DetailScaffold(
              title: l10n.clientsNewClient,
              bottomAction: Column(children: [
                AppFilledButton(
                    label: l10n.clientsCreateClient, onPressed: () {}),
                const SizedBox(height: 8),
                AppGhostButton(label: l10n.coreCancel, onPressed: () {}),
                const SizedBox(height: 8),
                AppGhostButton(label: l10n.coreDraftDiscard, onPressed: () {}),
              ]),
              children: [
                for (var i = 0; i < 12; i++)
                  FormSectionCard(eyebrow: l10n.clientsContactInfo, children: [
                    LabelledField(
                      label: l10n.clientsFullName,
                      child: AppTextField(
                          controller: TextEditingController(),
                          hint: l10n.clientsFullName),
                    ),
                  ]),
              ],
            );
          }),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        expect(find.byType(PinnedActionBar), findsOneWidget);
      });
    }
  }
}
