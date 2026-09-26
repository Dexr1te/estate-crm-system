import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'responsive_harness.dart';

final _now = DateTime(2026, 9, 26, 15, 10);
final _since = DateTime(2026, 9, 26, 14, 32);

Widget _app(ValueNotifier<DateTime?> status, VoidCallback onRetry) =>
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => OfflineBanner(
        status: status,
        onRetry: onRetry,
        child: child!,
      ),
      home: const Scaffold(body: SafeArea(child: Text('client list'))),
    );

void main() {
  setUpAll(() => initializeDateFormatting('en'));
  setUp(() => AppClock.freeze(_now));
  tearDown(AppClock.reset);

  test('today it names the time; any other day, the date too', () {
    expect(offlineSinceLabel(_since, 'en'), '14:32');
    expect(
        offlineSinceLabel(DateTime(2026, 9, 24, 9, 5), 'en'), 'Sep 24, 09:05');
  });

  testWidgets('the banner comes with cached data and goes with fresh data',
      (tester) async {
    final status = ValueNotifier<DateTime?>(null);
    var retries = 0;
    await tester.pumpWidget(_app(status, () => retries++));

    expect(find.byKey(const Key('offline-banner')), findsNothing);
    expect(find.text('client list'), findsOneWidget);

    status.value = _since;
    await tester.pump();
    expect(find.text('Offline — showing data from 14:32'), findsOneWidget);
    expect(find.text('client list'), findsOneWidget,
        reason: 'the screen under it stays');

    await tester.tap(find.text('Retry'));
    expect(retries, 1);

    status.value = null;
    await tester.pump();
    expect(find.byKey(const Key('offline-banner')), findsNothing);
  });

  testWidgets('the screen under the banner keeps its state', (tester) async {
    final status = ValueNotifier<DateTime?>(null);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) =>
          OfflineBanner(status: status, onRetry: () {}, child: child!),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: TextField()),
    ));
    await tester.enterText(find.byType(TextField), 'half-typed note');

    status.value = _since;
    await tester.pump();
    expect(find.text('half-typed note'), findsOneWidget);

    status.value = null;
    await tester.pump();
    expect(find.text('half-typed note'), findsOneWidget);
  });

  forEachAcceptanceCase('offline banner',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        OfflineBanner(
          status: ValueNotifier(DateTime(2026, 9, 24, 14, 32)),
          onRetry: () {},
          child: const Scaffold(body: Text('client list')),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      expect(find.byKey(const Key('offline-banner')), findsOneWidget);
    }
  });
}
