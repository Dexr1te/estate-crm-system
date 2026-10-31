import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Where a manager starts bringing an agency's book in from a spreadsheet.
class ImportSettingsRow extends StatelessWidget {
  const ImportSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsRow(
      key: const ValueKey('import-entry'),
      label: l10n.importTitle,
      subLabel: l10n.importEntrySubtitle,
      showChevron: true,
      onTap: () => context.push('/import'),
    );
  }
}
