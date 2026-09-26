import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_sheet.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The app's one "+". A tab puts it where its header action always sat,
/// labelled; a record's app bar and the dashboard carry it as a tile beside
/// their other icons. Either way it opens the same sheet.
class QuickAddButton extends StatelessWidget {
  final bool compact;
  final VoidCallback? onDone;

  const QuickAddButton({super.key, this.compact = false, this.onDone});

  const QuickAddButton.tile({super.key, this.onDone}) : compact = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open() => showQuickAddSheet(context, onDone: onDone);
    if (compact) {
      return AppIconTile(
        key: const ValueKey('quick-add'),
        icon: Icons.add_rounded,
        tooltip: l10n.quickAddOpen,
        onPressed: open,
      );
    }
    return AppHeaderAction(
      key: const ValueKey('quick-add'),
      label: l10n.quickAddOpen,
      onPressed: open,
    );
  }
}
