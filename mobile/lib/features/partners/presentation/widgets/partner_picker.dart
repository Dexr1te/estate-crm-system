import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/partner_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Picks one of the agency's partners, searchable by name, kind or company.
/// Resolves to null when the sheet is dismissed; a failure to load reads as
/// an empty list, and the picker says so.
Future<PickerItem?> showPartnerPicker(BuildContext context,
    {int? selectedId}) async {
  final l10n = AppLocalizations.of(context);
  List<Partner> partners;
  try {
    partners = await Injector.partnersRepository.getPartners();
  } catch (_) {
    partners = const [];
  }
  if (!context.mounted) return null;
  return showEntityPicker(
    context,
    title: l10n.partnersPickPartner,
    searchHint: l10n.partnersSearchHint,
    emptyLabel: l10n.partnersPickerEmpty,
    selectedId: selectedId,
    items: [
      for (final p in partners)
        PickerItem(id: p.id, title: p.name, subtitle: partnerSubtitle(l10n, p)),
    ],
  );
}
