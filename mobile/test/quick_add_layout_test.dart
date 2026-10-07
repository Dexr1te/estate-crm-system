import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/quick_add/quick_add.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_button.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_menu.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);

/// The sheet as it opens over a record: linked to someone with a long name,
/// the last action used leading with its tag.
Widget _sheet() => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AppSheetShell(
          title: 'Add',
          child: QuickAddMenu(
            actions: orderQuickAdd(QuickAddAction.values,
                lastUsed: QuickAddAction.logContact),
            lastUsed: QuickAddAction.logContact,
            linkedTo: Future.value('Irina Alexandrovna Sokolova-Kuznetsova'),
            onPick: (_) {},
          ),
        ),
      ),
    );

/// The two shapes of the "+" in a header row beside a long title.
Widget _headers() => BlocProvider(
      create: (_) =>
          AuthBloc(FakeAuthRepository(user: _agent))..add(AuthCheckEvent()),
      child: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(children: [
                Expanded(
                    child: ScreenTitle('Clients and a very long team name')),
                SizedBox(width: 12),
                QuickAddButton(),
              ]),
              DetailAppBar(
                title: 'Irina Alexandrovna Sokolova-Kuznetsova',
                actions: [QuickAddButton.tile()],
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  forEachAcceptanceCase('quick-add sheet',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(tester, _sheet(),
          size: size, brightness: brightness, textScale: scale, locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} once the link has resolved');
      expect(
          find.byKey(const ValueKey('quick-add-logContact')), findsOneWidget);
    }
  });

  forEachAcceptanceCase('quick-add button in a header',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(tester, _headers(),
          size: size, brightness: brightness, textScale: scale, locale: locale);
      final tile = tester.getSize(find.descendant(
          of: find.byType(QuickAddButton), matching: find.byType(AppIconTile)));
      expect(tile.width, greaterThanOrEqualTo(AppMetrics.minHitTarget));
      expect(tester.getSize(find.byType(AppHeaderAction)).height,
          greaterThanOrEqualTo(AppMetrics.minHitTarget));
    }
  });
}
