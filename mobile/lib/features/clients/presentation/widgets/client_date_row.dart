import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/domain/client_birthday.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One birthday or purchase anniversary coming up: whose, what, when, and the
/// call and greeting a tap away.
class ClientDateRow extends StatelessWidget {
  final UpcomingClientDate date;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onGreet;
  final bool nested;

  /// Whose client it is — for a manager looking at the agency's dates.
  final bool showAgent;

  const ClientDateRow({
    super.key,
    required this.date,
    required this.onTap,
    required this.onCall,
    required this.onGreet,
    this.nested = false,
    this.showAgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = date.daysAway <= 0;
    final when = l10n.clientsDatesWhen(clientDateWhenLabel(l10n, date.daysAway),
        formatDayMonth(date.date, locale));
    final meta = [
      if (date.kind == ClientDateKind.purchaseAnniversary)
        date.propertyTitle ?? date.dealTitle,
      if (showAgent) date.agentName,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' · ');
    final key = '${date.kind.name}-${date.clientId}-${date.dealId ?? 0}';

    return AppCard(
      key: ValueKey('client-date-$key'),
      nested: nested,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                    date.kind == ClientDateKind.purchaseAnniversary
                        ? Icons.vpn_key_outlined
                        : Icons.cake_outlined,
                    size: 17,
                    color: t.textSecondary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary)),
                    const SizedBox(height: 2),
                    Text(clientDateWhatLabel(l10n, date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 12,
                            color: t.textSecondary)),
                    const SizedBox(height: 2),
                    Text(when,
                        key: ValueKey('client-date-when-$key'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: today
                                ? t.statusText(StatusHue.positive)
                                : t.textPrimary)),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppGhostButton(
                  key: ValueKey('client-date-call-$key'),
                  label: l10n.coreCall,
                  icon: Icons.phone_outlined,
                  onPressed: onCall,
                  height: AppMetrics.buttonHeightInline,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppGhostButton(
                  key: ValueKey('client-date-greet-$key'),
                  label: l10n.clientsDatesGreet,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: onGreet,
                  height: AppMetrics.buttonHeightInline,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The skeleton of a [ClientDateRow], shaped like one.
class ClientDateRowBone extends StatelessWidget {
  const ClientDateRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 34, height: 34, radius: 10),
          titleFactor: 0.5,
          subtitleFactor: 0.35,
        ),
      );
}
