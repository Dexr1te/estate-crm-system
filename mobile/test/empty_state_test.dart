import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  // EmptyState fills the height it is given so it can sit centred in a list.
  // In a bottom sheet there is no height to fill — the column is min-sized —
  // and asking for it back demanded an infinite child, so the picker's
  // "nothing found" rendered as an empty sheet. From the outside that looked
  // like tapping the field only dimmed the screen.
  testWidgets('an empty state still says its piece where height is unbounded',
      (tester) async {
    await tester.pumpWidget(_host(
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyState(icon: Icons.search_off_rounded, title: 'Nothing found'),
        ],
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('Nothing found'), findsOneWidget);
  });

  testWidgets('and still centres itself where there is height to fill',
      (tester) async {
    await tester.pumpWidget(_host(
      const SizedBox(
        height: 600,
        child: EmptyState(icon: Icons.inbox_outlined, title: 'Nothing here'),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('a picker with nothing to pick explains itself', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_host(Builder(builder: (c) {
      ctx = c;
      return const SizedBox.shrink();
    })));

    showEntityPicker(
      ctx,
      title: 'Agent',
      items: const [],
      searchHint: 'Search',
      emptyLabel: 'No agents to assign',
    );
    await tester.pumpAndSettle();

    expect(find.text('No agents to assign'), findsOneWidget,
        reason: 'an empty sheet reads as a broken tap');
  });
}
