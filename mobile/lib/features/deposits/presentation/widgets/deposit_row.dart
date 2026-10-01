import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One deposit whose hold is running out: which deal, how long is left (or
/// how long ago it ended), the amount, the buyer and the agent.
class DepositRow extends StatelessWidget {
  final DealDeposit deposit;
  final VoidCallback onTap;
  final bool nested;

  const DepositRow({
    super.key,
    required this.deposit,
    required this.onTap,
    this.nested = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final days = depositDaysLeft(deposit.holdUntil, AppClock.now());
    final meta = [
      formatPrice(deposit.amount),
      deposit.clientName,
      deposit.agentName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final title = deposit.propertyTitle?.isNotEmpty == true
        ? deposit.propertyTitle!
        : deposit.dealTitle;

    return AppCard(
      key: ValueKey('deposit-row-${deposit.id}'),
      nested: nested,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.surfaceVariant,
              borderRadius: BorderRadius.circular(11),
            ),
            child:
                Icon(Icons.savings_outlined, size: 19, color: t.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
                const SizedBox(height: 2),
                Text(depositTimeLeftLabel(l10n, days),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: t.dangerText)),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11.5,
                          color: t.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The skeleton of a [DepositRow], shaped like one.
class DepositRowBone extends StatelessWidget {
  const DepositRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 38, height: 38, radius: 11),
          titleFactor: 0.55,
          subtitleFactor: 0.4,
        ),
      );
}
