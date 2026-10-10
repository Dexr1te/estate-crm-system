import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager console's way into what the agency still owes from split
/// commissions.
class PayoutsSettingsRow extends StatelessWidget {
  const PayoutsSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('payouts-row'),
        label: l10n.payoutsTitle,
        subLabel: l10n.payoutsHint,
        showChevron: true,
        onTap: () => context.push('/payouts'),
      ),
    ]);
  }
}
