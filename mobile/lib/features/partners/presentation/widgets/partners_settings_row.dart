import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The profile's way into the agency's partners, for anyone in an agency.
class PartnersSettingsRow extends StatelessWidget {
  const PartnersSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('partners-row'),
        label: l10n.partnersTitle,
        subLabel: l10n.partnersHint,
        showChevron: true,
        onTap: () => context.push('/partners'),
      ),
    ]);
  }
}
