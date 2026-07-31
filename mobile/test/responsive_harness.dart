import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The acceptance matrix from the design handoff: every screen must render
/// with zero overflow at each of these sizes, in both themes, at text scale
/// 1.0 and 1.3.
const kAcceptanceSizes = <Size>[
  Size(320, 568), // iPhone SE 1st gen
  Size(375, 667), // iPhone SE 2nd/3rd gen
  Size(390, 844), // reference — the size the mocks are drawn at
  Size(430, 932), // Pro Max
  Size(768, 1024), // tablet
];

const kAcceptanceTextScales = <double>[1.0, 1.3];

const kAcceptanceLocales = <Locale>[Locale('en'), Locale('ru'), Locale('kk')];

/// Pumps [child] inside a themed, localised app at a fixed size and text
/// scale, then fails if the frame produced any layout overflow.
///
/// Overflow surfaces as a `FlutterError` during paint, which the test binding
/// records; [WidgetTester.takeException] is how we assert on it.
Future<void> expectNoOverflow(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required Brightness brightness,
  required double textScale,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppThemeDark.dark,
      themeMode:
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
          padding: const EdgeInsets.only(top: 47, bottom: 34),
          viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
        ),
        child: child,
      ),
    ),
  );
  await tester.pump();

  final error = tester.takeException();
  expect(
    error,
    isNull,
    reason: 'overflow at ${size.width}×${size.height}, '
        '$brightness, textScale $textScale, ${locale.languageCode}',
  );
}

/// Runs [body] once per (size × theme × text scale) combination.
void forEachAcceptanceCase(
  String description,
  Future<void> Function(WidgetTester tester, Size size, Brightness brightness,
          double textScale)
      body,
) {
  for (final size in kAcceptanceSizes) {
    for (final brightness in Brightness.values) {
      for (final scale in kAcceptanceTextScales) {
        testWidgets(
          '$description — ${size.width.toInt()}×${size.height.toInt()} '
          '${brightness.name} ${scale}x',
          (tester) => body(tester, size, brightness, scale),
        );
      }
    }
  }
}
