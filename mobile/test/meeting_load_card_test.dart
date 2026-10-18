import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/meeting_load_card.dart';

import 'responsive_harness.dart';

final _today = DateTime(2026, 10, 18);
final _empty = List.filled(14, 0);
final _busy = [1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

Widget _card(List<int> load) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MeetingLoadCard(load: load, today: _today, onTap: () {}),
        ],
      ),
    );

Future<void> _show(WidgetTester tester, List<int> load,
        {Size size = const Size(390, 844),
        Brightness brightness = Brightness.light,
        double textScale = 1.0,
        Locale locale = const Locale('en')}) =>
    expectNoOverflow(tester, _card(load),
        size: size,
        brightness: brightness,
        textScale: textScale,
        locale: locale);

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('two empty weeks say so in words, not with a blank chart',
      (tester) async {
    await _show(tester, _empty);

    expect(find.text('No meetings in the next 14 days'), findsOneWidget);
    expect(find.text('Booked meetings will show here, day by day'),
        findsOneWidget);
    expect(find.text('nothing booked'), findsNothing);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('booked weeks show the count and the days', (tester) async {
    await _show(tester, _busy);

    expect(find.text('3 meetings'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('No meetings in the next 14 days'), findsNothing);
  });

  forEachAcceptanceCase('empty meeting load',
      (tester, size, brightness, scale) async {
    await _show(tester, _empty,
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('empty meeting load reads in ${locale.languageCode}',
        (tester) async {
      await _show(tester, _empty,
          size: const Size(320, 568), textScale: 1.5, locale: locale);
    });
  }
}
