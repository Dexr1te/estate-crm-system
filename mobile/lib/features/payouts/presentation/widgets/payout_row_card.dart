import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/payout_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/payout_widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Who a share goes to, under their name: a co-broker and their agency; a
/// colleague needs no word.
String? payoutPartyLabel(
    AppLocalizations l10n, CommissionPartyKind kind, String? agency) {
  if (kind != CommissionPartyKind.CO_BROKER) return null;
  final from = agency?.trim() ?? '';
  return from.isEmpty ? l10n.splitsCoBroker : l10n.splitsCoBrokerFrom(from);
}

/// One share of a won deal on the payouts screen: the deal, what the share
/// comes to, and whether it has been paid. [showParty] names whose it is, for
/// a manager reading the whole agency's.
class PayoutRowCard extends StatelessWidget {
  final PayoutItem item;
  final bool showParty;
  final VoidCallback? onTap;

  const PayoutRowCard({
    super.key,
    required this.item,
    required this.showParty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final amount = item.amount;
    final title = item.dealTitle.trim();
    final note = item.note?.trim() ?? '';
    final percent = l10n.splitsPercent(formatRate(item.percent));
    final party = payoutPartyLabel(l10n, item.kind, item.agency);
    final who = [
      if (showParty)
        item.agentName.trim().isEmpty
            ? l10n.changeLogNoValue
            : item.agentName.trim(),
      if (showParty && party != null) party,
      percent,
    ].join(' · ');
    final closedAt = item.closedAt;
    final paidBy = item.paidByName?.trim() ?? '';
    final hint = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11.5, color: t.textSecondary);

    return AppCard(
      key: ValueKey('payout-${item.shareId}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? l10n.changeLogNoValue : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(who,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: hint),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 2,
                child: Text(
                  amount == null ? l10n.payoutsNoAmount : formatPrice(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: amount == null ? 12 : 13.5,
                      fontWeight:
                          amount == null ? FontWeight.w500 : FontWeight.w600,
                      color: amount == null ? t.textHint : t.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PayoutChip(paid: item.paid, paidAt: item.paidAt),
              if (!item.paid && closedAt != null)
                Text(l10n.payoutsWonOn(formatFullDate(closedAt, locale)),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: hint),
              if (item.paid && paidBy.isNotEmpty)
                Text(l10n.payoutsMarkedBy(paidBy),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: hint),
            ],
          ),
          if (item.paid && note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: hint.copyWith(height: 1.4)),
          ],
        ],
      ),
    );
  }
}

/// What one person is still owed, in the manager's list at the top.
class PayoutOwedRow extends StatelessWidget {
  final PayoutPartyTotal total;

  const PayoutOwedRow({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final name = total.name.trim();
    final party = payoutPartyLabel(l10n, total.kind, total.agency);
    final sub = [
      if (party != null) party,
      l10n.payoutsShareCount(total.shares),
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? l10n.changeLogNoValue : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    color: t.textHint),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Text(
            formatPrice(total.unpaid),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.textPrimary),
          ),
        ),
      ],
    );
  }
}
