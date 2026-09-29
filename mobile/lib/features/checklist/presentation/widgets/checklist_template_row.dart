import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager console's way into the agency's deal checklist.
class ChecklistTemplateSettingsRow extends StatelessWidget {
  const ChecklistTemplateSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('checklist-template-row'),
        label: l10n.teamsChecklist,
        subLabel: l10n.teamsChecklistHint,
        showChevron: true,
        onTap: () => context.push('/checklist-template'),
      ),
    ]);
  }
}
