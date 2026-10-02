import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager console's way into the agent leaderboard.
class LeaderboardSettingsRow extends StatelessWidget {
  const LeaderboardSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('leaderboard-row'),
        label: l10n.leaderboardTitle,
        subLabel: l10n.leaderboardHint,
        showChevron: true,
        onTap: () => context.push('/leaderboard'),
      ),
    ]);
  }
}
