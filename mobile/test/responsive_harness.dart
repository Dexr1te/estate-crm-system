import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const kAcceptanceSizes = <Size>[
  Size(320, 568),
  Size(375, 667),
  Size(390, 844),
  Size(430, 932),
  Size(768, 1024),
];

const kAcceptanceTextScales = <double>[1.0, 1.3];

const kAcceptanceLocales = <Locale>[Locale('en'), Locale('ru'), Locale('kk')];

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
