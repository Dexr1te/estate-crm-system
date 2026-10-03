import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager console's way into the agency's change log.
class ChangeLogSettingsRow extends StatelessWidget {
  const ChangeLogSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('change-log-row'),
        label: l10n.changeLogTeamTitle,
        subLabel: l10n.changeLogTeamHint,
        showChevron: true,
        onTap: () => context.push('/audit'),
      ),
    ]);
  }
}

/// The way from a listing, deal or client into its history of changes, at
/// [location].
class ChangeHistoryButton extends StatelessWidget {
  final String location;
  const ChangeHistoryButton({super.key, required this.location});

  @override
  Widget build(BuildContext context) => AppGhostButton(
        key: const ValueKey('change-history'),
        label: AppLocalizations.of(context).changeLogTitle,
        icon: Icons.history_rounded,
        onPressed: () => context.push(location),
      );
}
