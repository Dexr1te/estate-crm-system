import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deposits/presentation/bloc/deposits_ending_bloc.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many deposits the dashboard shows before "See all".
const kDepositsPreview = 3;

/// The deposits whose hold is running out, on the dashboard: the soonest few,
/// each opening its deal. Nothing at all when none is, a skeleton while it
/// loads, and a failure stays inside the card. Mirrors the agreements card.
///
/// [topGap] sits above the card and goes with it, so a hidden card leaves no
/// hole in the column.
class DepositsEndingCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  final double topGap;

  const DepositsEndingCard({
    super.key,
    required this.onSeeAll,
    this.topGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositsEndingBloc, DepositsEndingState>(
      builder: (context, state) {
        if (state is DepositsEndingLoaded && state.deposits.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('deposits-hidden'));
        }
        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: _card(context, state),
        );
      },
    );
  }

  Widget _card(BuildContext context, DepositsEndingState state) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final all = state is DepositsEndingLoaded ? state.deposits : null;
    final shown = all?.take(kDepositsPreview).toList();
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);

    return AppCard(
      key: const ValueKey('deposits-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.depositsEndingTitle)),
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
          if (state is DepositsEndingError) ...[
            Text(l10n.depositsEndingLoadFailed,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
            const SizedBox(height: 10),
            AppGhostButton(
              key: const ValueKey('deposits-retry'),
              label: l10n.coreRetry,
              onPressed: () => context
                  .read<DepositsEndingBloc>()
                  .add(DepositsEndingLoadEvent()),
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ] else if (shown == null)
            const Column(children: [
              DepositRowBone(),
              SizedBox(height: 8),
              DepositRowBone(),
            ])
          else ...[
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              DepositRow(
                deposit: shown[i],
                nested: true,
                onTap: () => context.push('/deals/${shown[i].dealId}'),
              ),
            ],
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('deposits-see-all'),
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
