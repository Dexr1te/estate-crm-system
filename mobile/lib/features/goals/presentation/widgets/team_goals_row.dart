import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager console's way into the agency's monthly goals.
class TeamGoalsSettingsRow extends StatelessWidget {
  const TeamGoalsSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('team-goals-row'),
        label: l10n.goalsTeamTitle,
        subLabel: l10n.goalsTeamHint,
        showChevron: true,
        onTap: () => context.push('/team-goals'),
      ),
    ]);
  }
}
