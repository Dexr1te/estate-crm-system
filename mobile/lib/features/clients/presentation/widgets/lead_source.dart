import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How a client reached the agency, in words; null reads as not recorded.
String leadSourceLabel(AppLocalizations l10n, LeadSource? source) {
  switch (source) {
    case LeadSource.REFERRAL:
      return l10n.clientsLeadSourceReferral;
    case LeadSource.WEBSITE:
      return l10n.clientsLeadSourceWebsite;
    case LeadSource.PORTAL:
      return l10n.clientsLeadSourcePortal;
    case LeadSource.SOCIAL:
      return l10n.clientsLeadSourceSocial;
    case LeadSource.WALK_IN:
      return l10n.clientsLeadSourceWalkIn;
    case LeadSource.COLD_CALL:
      return l10n.clientsLeadSourceColdCall;
    case LeadSource.REPEAT:
      return l10n.clientsLeadSourceRepeat;
    case LeadSource.PARTNER:
      return l10n.clientsLeadSourcePartner;
    case LeadSource.OTHER:
      return l10n.clientsLeadSourceOther;
    case null:
      return l10n.clientsLeadSourceNone;
  }
}

/// The source a server name stands for; `UNKNOWN` and anything newer than
/// the app read as null.
LeadSource? leadSourceFromName(String name) {
  for (final s in LeadSource.values) {
    if (s.name == name) return s;
  }
  return null;
}

/// "Referral · Dana, the neighbour", or the source alone. A client a partner
/// sent names the [partner] first: "Partner · Ainur Sadykova · mortgage".
String leadSourceText(AppLocalizations l10n, LeadSource source, String? detail,
    {String? partner}) {
  final parts = [
    leadSourceLabel(l10n, source),
    if (source == LeadSource.PARTNER && (partner?.trim().isNotEmpty ?? false))
      partner!.trim(),
    if (detail != null && detail.trim().isNotEmpty) detail.trim(),
  ];
  return parts.join(' · ');
}

/// The client form's "Where they came from": one source or none, and a
/// detail beside it once a source is chosen. With PARTNER chosen it also asks
/// which of the agency's partners, through [onPickPartner].
class LeadSourceField extends StatelessWidget {
  final LeadSource? source;
  final ValueChanged<LeadSource?> onChanged;
  final TextEditingController detailCtrl;

  /// The partner picked for PARTNER, by name; null while none is.
  final String? partnerName;
  final VoidCallback? onPickPartner;

  /// Said under the partner field when the form was sent without one.
  final String? partnerError;

  const LeadSourceField({
    super.key,
    required this.source,
    required this.onChanged,
    required this.detailCtrl,
    this.partnerName,
    this.onPickPartner,
    this.partnerError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const pad = EdgeInsets.symmetric(horizontal: 15, vertical: 9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterPillWrap(pills: [
          FilterPill(
            key: const ValueKey('lead-source-none'),
            label: l10n.clientsLeadSourceNone,
            selected: source == null,
            onCard: true,
            onTap: () => onChanged(null),
            padding: pad,
          ),
          for (final s in LeadSource.values)
            FilterPill(
              key: ValueKey('lead-source-${s.name}'),
              label: leadSourceLabel(l10n, s),
              selected: source == s,
              onCard: true,
              onTap: () => onChanged(s),
              padding: pad,
            ),
        ]),
        if (source == LeadSource.PARTNER && onPickPartner != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: LabelledField(
              label: l10n.partnersHandoffPartner,
              required: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PickerField(
                    key: const ValueKey('lead-source-partner'),
                    value: partnerName,
                    placeholder: l10n.partnersPickPartner,
                    onTap: onPickPartner!,
                    trailingIcon: Icons.handshake_outlined,
                  ),
                  if (partnerError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      partnerError!,
                      key: const ValueKey('lead-source-partner-error'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11.5,
                          color: context.tokens.dangerText),
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (source != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: LabelledField(
              label: l10n.clientsLeadSourceDetail,
              child: AppTextField(
                key: const ValueKey('lead-source-detail'),
                controller: detailCtrl,
                hint: l10n.clientsLeadSourceDetailHint,
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
      ],
    );
  }
}

/// Picks the source the clients list is narrowed to, with how many clients on
/// the list came through each. Resolves to `(source: null)` for all sources,
/// or null when the sheet is dismissed.
Future<({LeadSource? source})?> showLeadSourceFilter(
  BuildContext context, {
  required Map<LeadSource, int> counts,
  required LeadSource? selected,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<({LeadSource? source})>(
    context,
    title: l10n.clientsLeadSource,
    builder: (sheet) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: FilterPillWrap(pills: [
        FilterPill(
          key: const ValueKey('lead-source-filter-all'),
          label: l10n.clientsFilterSourceAll,
          selected: selected == null,
          onCard: true,
          onTap: () => Navigator.pop(sheet, (source: null)),
        ),
        for (final s in LeadSource.values)
          FilterPill(
            key: ValueKey('lead-source-filter-${s.name}'),
            label: '${leadSourceLabel(l10n, s)} · ${counts[s] ?? 0}',
            selected: selected == s,
            onCard: true,
            onTap: () => Navigator.pop(sheet, (source: s)),
          ),
      ]),
    ),
  );
}
