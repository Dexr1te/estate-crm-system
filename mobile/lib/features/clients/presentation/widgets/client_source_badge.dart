import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Where a card came from, when that is worth saying: a buyer who left their
/// details on a listing's public page, or a row from a spreadsheet. A card an
/// agent typed in carries no badge.
class ClientSourceBadge extends StatelessWidget {
  final ClientSource source;

  const ClientSourceBadge({super.key, required this.source});

  static bool shows(ClientSource source) => source != ClientSource.manual;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (source) {
      case ClientSource.publicLink:
        return StatusChip(
            key: const ValueKey('client-source-public-link'),
            label: l10n.clientsSourcePublicLink,
            hue: StatusHue.positive);
      case ClientSource.openHouse:
        return StatusChip(
            key: const ValueKey('client-source-open-house'),
            label: l10n.clientsSourceOpenHouse,
            hue: StatusHue.positive);
      case ClientSource.imported:
        return StatusChip(
            key: const ValueKey('client-source-import'),
            label: l10n.clientsSourceImport,
            hue: StatusHue.neutral);
      case ClientSource.manual:
        return const SizedBox.shrink();
    }
  }
}
