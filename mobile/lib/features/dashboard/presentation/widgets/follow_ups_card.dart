import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/cold_clients_repository.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One row into each follow-up list, whether or not it holds anything: who
/// is going cold, birthdays and anniversaries, seller agreements, keys out,
/// deposits and leases ending.
///
/// The cards above it only show up with something urgent in them, so a new
/// user would never learn these lists exist. Here the way in is always
/// there, each row saying what its list holds; an empty list says how it
/// fills up.
///
/// [topGap] sits above it and goes with it.
class FollowUpsCard extends StatelessWidget {
  final double topGap;

  const FollowUpsCard({super.key, this.topGap = 0});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final pad = AppMetrics.cardPadding(context);
    final rows = [
      _FollowUpRow(
        key: const ValueKey('follow-ups-cold'),
        icon: Icons.ac_unit_rounded,
        title: l10n.clientsColdTitle,
        hint: l10n.clientsColdSubtitle(ColdClientsRepository.defaultDays),
        onTap: () => context.push('/clients/cold'),
      ),
      _FollowUpRow(
        key: const ValueKey('follow-ups-dates'),
        icon: Icons.cake_outlined,
        title: l10n.clientsDatesTitle,
        hint: l10n.dashboardFollowUpsDatesHint,
        onTap: () => context.push('/clients/dates'),
      ),
      _FollowUpRow(
        key: const ValueKey('follow-ups-mandates'),
        icon: Icons.handshake_outlined,
        title: l10n.propertiesMandatesTitle,
        hint: l10n.dashboardFollowUpsMandatesHint,
        onTap: () => context.push('/properties/mandates'),
      ),
      _FollowUpRow(
        key: const ValueKey('follow-ups-keys'),
        icon: Icons.key_outlined,
        title: l10n.keysOutTitle,
        hint: l10n.dashboardFollowUpsKeysHint,
        onTap: () => context.push('/properties/keys'),
      ),
      _FollowUpRow(
        key: const ValueKey('follow-ups-deposits'),
        icon: Icons.savings_outlined,
        title: l10n.depositsEndingTitle,
        hint: l10n.dashboardFollowUpsDepositsHint,
        onTap: () => context.push('/deals/deposits'),
      ),
      _FollowUpRow(
        key: const ValueKey('follow-ups-leases'),
        icon: Icons.event_busy_outlined,
        title: l10n.leasesEndingTitle,
        hint: l10n.dashboardFollowUpsLeasesHint,
        onTap: () => context.push('/deals/leases'),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(top: topGap),
      child: AppCard(
        key: const ValueKey('follow-ups-card'),
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 14, pad, 4),
                child: EyebrowLabel(l10n.dashboardFollowUps),
              ),
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Container(height: 1, color: t.border),
                rows[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;

  const _FollowUpRow({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppMetrics.minHitTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppMetrics.cardPadding(context), vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: t.textSecondary),
                const SizedBox(width: 12),
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
                            fontSize: AppType.body,
                            fontWeight: FontWeight.w500,
                            color: t.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: AppType.footnote,
                            height: 1.3,
                            color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const RowChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
