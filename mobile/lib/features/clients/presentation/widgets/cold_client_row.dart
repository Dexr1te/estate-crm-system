import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String coldSilenceLabel(AppLocalizations l10n, ColdClient client) =>
    client.lastContactAt == null
        ? l10n.clientsColdNeverContacted
        : l10n.clientsColdSilentDays(client.silentDays);

String coldReasonLabel(AppLocalizations l10n, ColdReason reason) =>
    switch (reason.code) {
      ColdReasonCode.openDeal => reason.dealStatus == DealStatus.NEGOTIATION
          ? l10n.clientsColdReasonNegotiation
          : l10n.clientsColdReasonOpenDeal,
      ColdReasonCode.matches =>
        l10n.clientsColdReasonMatches(reason.matchCount ?? 0),
      ColdReasonCode.newLead => l10n.clientsColdReasonLead,
      ColdReasonCode.unknown => '',
    };

StatusHue coldReasonHue(ColdReason reason) => switch (reason.code) {
      ColdReasonCode.openDeal => reason.dealStatus == DealStatus.NEGOTIATION
          ? StatusHue.negotiation
          : StatusHue.lead,
      ColdReasonCode.matches => StatusHue.positive,
      _ => StatusHue.neutral,
    };

String? coldNextStepLabel(AppLocalizations l10n, ColdNextStep? step) =>
    switch (step) {
      ColdNextStep.pushDeal => l10n.clientsColdNextPushDeal,
      ColdNextStep.sendMatches => l10n.clientsColdNextSendMatches,
      ColdNextStep.firstCall => l10n.clientsColdNextFirstCall,
      ColdNextStep.checkIn => l10n.clientsColdNextCheckIn,
      null => null,
    };

/// One client going cold: who, how long, why, and the two quick actions.
class ColdClientRow extends StatelessWidget {
  final ColdClient client;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onRemind;
  final bool nested;

  /// Whether to name what the call should be about under the reasons.
  final bool showNextStep;

  const ColdClientRow({
    super.key,
    required this.client,
    required this.onTap,
    required this.onCall,
    required this.onRemind,
    this.nested = false,
    this.showNextStep = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final reasons = client.knownReasons;
    final hint = showNextStep ? coldNextStepLabel(l10n, client.nextStep) : null;

    return AppCard(
      key: ValueKey('cold-client-${client.id}'),
      nested: nested,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialAvatar(name: client.fullName, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary)),
                    const SizedBox(height: 2),
                    Text(coldSilenceLabel(l10n, client),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: t.dangerText)),
                  ],
                ),
              ),
            ],
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final r in reasons)
                  StatusChip(
                      label: coldReasonLabel(l10n, r), hue: coldReasonHue(r)),
              ],
            ),
          ],
          if (hint != null) ...[
            const SizedBox(height: 7),
            Text(hint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    color: t.textSecondary)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppGhostButton(
                  key: ValueKey('cold-call-${client.id}'),
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
                  key: ValueKey('cold-remind-${client.id}'),
                  label: l10n.clientsColdRemind,
                  icon: Icons.alarm_outlined,
                  onPressed: onRemind,
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

/// The skeleton of a [ColdClientRow], shaped like one.
class ColdClientRowBone extends StatelessWidget {
  const ColdClientRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerCircle(size: 34),
          titleFactor: 0.5,
          subtitleFactor: 0.35,
        ),
      );
}
