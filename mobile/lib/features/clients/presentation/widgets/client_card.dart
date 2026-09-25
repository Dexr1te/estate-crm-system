import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ClientCard extends StatelessWidget {
  final ClientSummary client;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    final lastContact = client.lastContactAt;
    final footerLeft = [
      if (lastContact != null)
        lastContactLabel(l10n, lastContact, AppClock.now(),
            Localizations.localeOf(context).toLanguageTag()),
      l10n.clientsDealCount(client.dealCount),
      if (client.agentName != null && client.agentName!.isNotEmpty)
        l10n.clientsAgentMeta(client.agentName!),
    ].join(' · ');

    final showValue = client.totalBudget > 0;
    final trailingLabel = showValue
        ? formatPrice(client.totalBudget)
        : (client.status == null ? '' : dealStatusLabel(l10n, client.status!));
    final trailingColor = showValue || client.status == null
        ? t.textPrimary
        : StatusPalette.resolve(t, dealStatusHue(client.status!)).label;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialAvatar(name: client.fullName, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                    if (client.phone != null && client.phone!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        client.phone!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ClientTypeChip(type: client.type),
            ],
          ),
          if (client.dealCount > 0 ||
              trailingLabel.isNotEmpty ||
              lastContact != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 11, bottom: 10),
              child: Container(height: 1, color: t.border),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    footerLeft,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        color: t.textSecondary),
                  ),
                ),
                if (trailingLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    trailingLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: trailingColor),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ClientCardBone extends StatelessWidget {
  const ClientCardBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ShimmerCircle(size: 42),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerBar(widthFactor: 0.62, height: 12),
                      SizedBox(height: 8),
                      ShimmerBar(widthFactor: 0.4, height: 10),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                ShimmerBox(width: 58, height: 22, radius: 11),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 11, bottom: 10),
              child: ShimmerBox(width: double.infinity, height: 1, radius: 0.5),
            ),
            Row(
              children: [
                Expanded(child: ShimmerBar(widthFactor: 0.54, height: 10)),
                SizedBox(width: 8),
                ShimmerBox(width: 56, height: 10, radius: 5),
              ],
            ),
          ],
        ),
      );
}
