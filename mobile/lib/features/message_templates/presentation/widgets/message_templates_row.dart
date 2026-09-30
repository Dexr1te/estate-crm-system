import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager console's way into the agency's message templates.
class MessageTemplatesSettingsRow extends StatelessWidget {
  const MessageTemplatesSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('message-templates-row'),
        label: l10n.templatesTitle,
        subLabel: l10n.templatesHint,
        showChevron: true,
        onTap: () => context.push('/message-templates'),
      ),
    ]);
  }
}
