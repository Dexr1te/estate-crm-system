import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/admin/presentation/widgets/invite_result_dialog.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'responsive_harness.dart';

const _invited = AgentResponse(
  id: 9,
  fullName: 'Aigerim Serikbaykyzy',
  email: 'aigerim.serikbaykyzy@estatecrm.kz',
  role: Role.AGENT,
  isActive: false,
  inviteToken: 'f3a9c2e1-7b4d-4e8a-9c1f-2d6b8e0a4c7f',
);

/// "Приглашение создано" beside its icon is wider than a small phone's dialog
/// once the text is enlarged, and the code under it is taller than a short
/// screen: the title wraps and the dialog scrolls instead of overflowing.
///
/// A dialog is built above `home`, so the text scale goes in through
/// `builder`, where it reaches the dialog too, the way my_app applies it.
void main() {
  for (final locale in kAcceptanceLocales) {
    for (final size in const [Size(320, 568), Size(375, 667)]) {
      for (final scale in kAcceptanceTextScales) {
        testWidgets(
            'the invite result fits — ${locale.languageCode} '
            '${size.width.toInt()}×${size.height.toInt()} ${scale}x',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.light,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => showInviteResultDialog(context, _invited),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ));
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsOneWidget);
          expect(tester.takeException(), isNull,
              reason: 'overflow in ${locale.languageCode} at ${scale}x');
        });
      }
    }
  }
}
