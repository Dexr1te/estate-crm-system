import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class AttentionRow extends StatelessWidget {
  final StaleDeal item;
  final VoidCallback onTap;

  const AttentionRow({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final rail =
        item.isSevere ? t.dangerText : t.statusText(StatusHue.negotiation);
    final amount = dealShownAmount(item.deal);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 34,
            decoration: BoxDecoration(
              color: rail,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.deal.title.isEmpty
                      ? l10n.dealsIdLabel(item.deal.id)
                      : item.deal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: AppType.body,
                      fontWeight: FontWeight.w500,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.dashboardIdleDays(item.idleDays),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: AppType.caption,
                      color: rail),
                ),
              ],
            ),
          ),
          if (amount > 0) ...[
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                item.deal.kind == DealKind.rent
                    ? leaseRentLabel(l10n, amount)
                    : formatPrice(amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: AppType.caption,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
