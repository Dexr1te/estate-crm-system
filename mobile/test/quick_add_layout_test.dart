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

Widget _shapes() => BlocProvider(
      create: (_) =>
          AuthBloc(FakeAuthRepository(user: _agent))..add(AuthCheckEvent()),
      child: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              DetailAppBar(
                title: 'Irina Alexandrovna Sokolova-Kuznetsova',
                actions: [QuickAddButton.tile()],
              ),
              SizedBox(width: 220, child: QuickAddButton.rail()),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: QuickAddButton.floating(),
              ),
            ],
          ),
        ),
      ),
    );

Finder _shape(QuickAddShape shape) =>
    find.byWidgetPredicate((w) => w is QuickAddButton && w.shape == shape,
        description: 'the $shape "+"');

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

  forEachAcceptanceCase('quick-add button shapes',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(tester, _shapes(),
          size: size, brightness: brightness, textScale: scale, locale: locale);
      final tile = tester.getSize(find.descendant(
          of: _shape(QuickAddShape.tile), matching: find.byType(AppIconTile)));
      expect(tile.width, greaterThanOrEqualTo(AppMetrics.minHitTarget));
      expect(tester.getSize(_shape(QuickAddShape.rail)).height,
          greaterThanOrEqualTo(AppMetrics.minHitTarget));
      final fab = tester.getSize(_shape(QuickAddShape.floating));
      expect(fab.width, QuickAddButton.floatingSize);
      expect(fab.height, QuickAddButton.floatingSize);
    }
  });
}
