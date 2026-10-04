import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/partner_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One hand-off in a list: on a client's card it names the partner, on a
/// partner's the client, with the day it was sent and where it has got to.
class HandoffRow extends StatelessWidget {
  final PartnerHandoff handoff;

  /// Name the client rather than the partner.
  final bool showClient;
  final VoidCallback? onTap;

  const HandoffRow({
    super.key,
    required this.handoff,
    this.showClient = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final h = handoff;
    final note = h.note?.trim();
    final title = showClient ? h.clientName : h.partnerName;
    final company = h.partnerCompany?.trim() ?? '';
    final meta = [
      formatFullDate(h.sentOn, locale),
      if (!showClient)
        company.isEmpty ? partnerKindLabel(l10n, h.partnerKind) : company,
      if (showClient && (h.sentByName?.trim().isNotEmpty ?? false))
        l10n.partnersHandoffBy(h.sentByName!.trim()),
    ].join(' · ');

    return AppCard(
      key: ValueKey('handoff-${h.id}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    note,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        height: 1.4,
                        color: t.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: StatusChip(
              label: handoffStatusLabel(l10n, h.status),
              hue: handoffStatusHue(h.status),
            ),
          ),
        ],
      ),
    );
  }
}
