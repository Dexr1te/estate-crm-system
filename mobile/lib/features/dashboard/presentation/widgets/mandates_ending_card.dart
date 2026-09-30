import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_state.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many listings the dashboard shows before "See all".
const kMandatesPreview = 3;

/// The listings whose seller agreement is running out, on the dashboard: the
/// soonest few, each opening its listing. Nothing at all when none is, a
/// skeleton while it loads, and a failure stays inside the card.
///
/// [topGap] sits above the card and goes with it, so a hidden card leaves no
/// hole in the column.
class MandatesEndingCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  final double topGap;

  const MandatesEndingCard({
    super.key,
    required this.onSeeAll,
    this.topGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MandatesBloc, MandatesState>(
      builder: (context, state) {
        if (state is MandatesLoaded && state.properties.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('mandates-hidden'));
        }
        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: _card(context, state),
        );
      },
    );
  }

  Widget _card(BuildContext context, MandatesState state) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final all = state is MandatesLoaded ? state.properties : null;
    final shown = all?.take(kMandatesPreview).toList();
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);

    return AppCard(
      key: const ValueKey('mandates-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.propertiesMandatesTitle)),
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
          if (state is MandatesError) ...[
            Text(l10n.propertiesMandatesLoadFailed,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
            const SizedBox(height: 10),
            AppGhostButton(
              key: const ValueKey('mandates-retry'),
              label: l10n.coreRetry,
              onPressed: () =>
                  context.read<MandatesBloc>().add(MandatesLoadEvent()),
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ] else if (shown == null)
            const Column(children: [
              MandateRowBone(),
              SizedBox(height: 8),
              MandateRowBone(),
            ])
          else ...[
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              MandateRow(
                property: shown[i],
                nested: true,
                onTap: () => context.push('/properties/${shown[i].id}'),
              ),
            ],
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('mandates-see-all'),
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
