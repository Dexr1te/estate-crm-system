import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/data/comparison_tray.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// On a listing's page: put it in the comparison tray or take it out, and,
/// once the tray holds anything, the way to open the comparison.
class CompareTrayControls extends StatefulWidget {
  final int propertyId;
  const CompareTrayControls({super.key, required this.propertyId});

  @override
  State<CompareTrayControls> createState() => _CompareTrayControlsState();
}

class _CompareTrayControlsState extends State<CompareTrayControls> {
  ComparisonTray get _tray => Injector.comparisonTray;

  @override
  void initState() {
    super.initState();
    _tray.load();
  }

  void _toggle() {
    final l10n = AppLocalizations.of(context);
    final change = _tray.toggle(widget.propertyId);
    showActionUnavailable(
      context,
      switch (change) {
        TrayChange.added => l10n.compareAdded,
        TrayChange.removed => l10n.compareRemoved,
        TrayChange.full => l10n.compareLimit,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _tray,
      builder: (context, _) {
        final inTray = _tray.contains(widget.propertyId);
        final toggle = AppGhostButton(
          key: const ValueKey('compare-tray-toggle'),
          label: inTray ? l10n.compareRemove : l10n.compareAdd,
          icon: inTray
              ? Icons.playlist_remove_rounded
              : Icons.compare_arrows_rounded,
          onPressed: _toggle,
        );
        if (_tray.length < 2) return toggle;
        return Row(
          children: [
            Expanded(flex: 3, child: toggle),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: AppGhostButton(
                key: const ValueKey('compare-tray-open'),
                label: l10n.compareBarButton(_tray.length),
                onPressed: () => context.push(compareLocation(_tray.ids)),
              ),
            ),
          ],
        );
      },
    );
  }
}
