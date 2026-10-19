import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const _size = Size(390, 844);
const _probeY = 700;

Future<List<(int, int, int)>> _row(WidgetTester tester, GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final pixels = <(int, int, int)>[];
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = (await image.toByteData())!;
    for (var x = 0; x < image.width; x++) {
      final i = (_probeY * image.width + x) * 4;
      pixels
          .add((data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2)));
    }
  });
  return pixels;
}

bool _red((int, int, int) p) => p.$1 > 180 && p.$2 < 90 && p.$3 < 90;

Future<void> _expectNoShowThrough(
    WidgetTester tester, ThemeData theme, Widget next) async {
  tester.view.physicalSize = _size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final navigator = GlobalKey<NavigatorState>();
  final boundary = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(
    key: boundary,
    child: MaterialApp(
      theme: theme,
      navigatorKey: navigator,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => AppBackdrop(child: child!),
      home: const Scaffold(
          body: SizedBox.expand(child: ColoredBox(color: Color(0xFFFF0000)))),
    ),
  ));

  unawaited(navigator.currentState!
      .push(MaterialPageRoute<void>(builder: (_) => next)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));

  final incoming = tester.getTopLeft(find.byWidget(next)).dx;
  expect(incoming, inExclusiveRange(0, _size.width - 40),
      reason: 'the probe has to land mid-transition');

  final row = await _row(tester, boundary);
  final shown = [
    for (var x = incoming.ceil() + 24; x < row.length; x++)
      if (_red(row[x])) x,
  ];
  expect(shown, isEmpty,
      reason: 'the page underneath shows through the one sliding in');

  await tester.pumpAndSettle();
}

void main() {
  final themes = {
    'light': AppTheme.light,
    'dark': AppThemeDark.forPlatform(TargetPlatform.iOS),
  };

  for (final entry in themes.entries) {
    final theme = entry.value.copyWith(platform: TargetPlatform.iOS);

    testWidgets(
        'a detail page slides in over the list, not through it '
        '(${entry.key})', (tester) async {
      await _expectNoShowThrough(
          tester, theme, const DetailScaffold(title: 'Deal', children: []));
    });

    testWidgets(
        'a plain screen slides in over the list, not through it '
        '(${entry.key})', (tester) async {
      await _expectNoShowThrough(
          tester, theme, const Scaffold(body: SizedBox.expand()));
    });
  }
}
