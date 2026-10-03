import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/leases/presentation/bloc/leases_ending_bloc.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many leases the dashboard shows before "See all".
const kLeasesPreview = 3;

/// The leases running out, on the dashboard: the soonest few, each with a
/// call to the tenant and the landlord, and opening its deal. Nothing at all
/// when none is, a skeleton while it loads, and a failure stays inside the
/// card. Mirrors the deposits card.
///
/// [topGap] sits above the card and goes with it, so a hidden card leaves no
/// hole in the column.
class LeasesEndingCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  final double topGap;

  const LeasesEndingCard({
    super.key,
    required this.onSeeAll,
    this.topGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeasesEndingBloc, LeasesEndingState>(
      builder: (context, state) {
        if (state is LeasesEndingLoaded && state.leases.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('leases-hidden'));
        }
        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: _card(context, state),
        );
      },
    );
  }

  Widget _card(BuildContext context, LeasesEndingState state) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final all = state is LeasesEndingLoaded ? state.leases : null;
    final shown = all?.take(kLeasesPreview).toList();
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);

    return AppCard(
      key: const ValueKey('leases-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.leasesEndingTitle)),
              if (all != null && all.length > shown!.length)
                Flexible(
                  child: Text(l10n.dashboardMandatesTotal(all.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: t.dangerText)),
                ),
            ],
          ),
          const SizedBox(height: 11),
          if (state is LeasesEndingError) ...[
            Text(l10n.leasesEndingLoadFailed,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
            const SizedBox(height: 10),
            AppGhostButton(
              key: const ValueKey('leases-retry'),
              label: l10n.coreRetry,
              onPressed: () =>
                  context.read<LeasesEndingBloc>().add(LeasesEndingLoadEvent()),
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ] else if (shown == null)
            const Column(children: [
              LeaseRowBone(),
              SizedBox(height: 8),
              LeaseRowBone(),
            ])
          else ...[
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              LeaseRow(
                lease: shown[i],
                nested: true,
                onTap: () => context.push('/deals/${shown[i].dealId}'),
              ),
            ],
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('leases-see-all'),
              label: l10n.dashboardSeeAll,
              onPressed: onSeeAll,
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ],
        ],
      ),
    );
  }
}
