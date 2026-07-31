import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ClientCard extends StatelessWidget {
  final ClientSummary client;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    final footerLeft = [
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
          if (client.dealCount > 0 || trailingLabel.isNotEmpty) ...[
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
  Widget build(BuildContext context) => const ShimmerBox(
      width: double.infinity, height: 96, radius: AppMetrics.radiusMd);
}
