import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_source_badge.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_tag_chips.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ClientCard extends StatelessWidget {
  final ClientSummary client;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.client, required this.onTap});

  /// Tags a row shows before counting the rest as "+N".
  static const maxVisibleTags = 3;

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

    final showMeta =
        client.dealCount > 0 || trailingLabel.isNotEmpty || lastContact != null;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialAvatar(name: client.fullName, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        client.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: t.textPrimary),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: trailingColor),
                      ),
                    ],
                  ],
                ),
                if (client.phone != null && client.phone!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    client.phone!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        color: t.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) => Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.55),
                        child: ClientTypeChip(type: client.type),
                      ),
                      if (showMeta) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            footerLeft,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: 12.5,
                                color: t.textHint),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (ClientSourceBadge.shows(client.source)) ...[
                  const SizedBox(height: 8),
                  ClientSourceBadge(source: client.source),
                ],
                if (client.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClientTagChips(tags: client.tags, maxVisible: maxVisibleTags),
                ],
              ],
            ),
          ),
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
        padding: EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerCircle(size: 44),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ShimmerBar(widthFactor: 0.62, height: 13)),
                      SizedBox(width: 8),
                      ShimmerBox(width: 52, height: 12, radius: 6),
                    ],
                  ),
                  SizedBox(height: 8),
                  ShimmerBar(widthFactor: 0.42, height: 11),
                  SizedBox(height: 10),
                  ShimmerBar(widthFactor: 0.7, height: 10),
                ],
              ),
            ),
          ],
        ),
      );
}
