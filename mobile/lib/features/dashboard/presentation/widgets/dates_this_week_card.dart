import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_date_actions.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_date_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many dates the dashboard shows before "See all".
const kDatesPreview = 3;

/// Birthdays and purchase anniversaries today and in the rest of the week, on
/// the dashboard, today's first. Nothing at all when there are none, a
/// skeleton while it loads, and a failure stays inside the card.
///
/// [topGap] sits above the card and goes with it, so a hidden card leaves no
/// hole in the column.
class DatesThisWeekCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  final double topGap;

  const DatesThisWeekCard({
    super.key,
    required this.onSeeAll,
    this.topGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientDatesBloc, ClientDatesState>(
      builder: (context, state) {
        if (state is ClientDatesLoaded && state.dates.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('dates-hidden'));
        }
        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: _card(context, state),
        );
      },
    );
  }

  Widget _card(BuildContext context, ClientDatesState state) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final all = state is ClientDatesLoaded ? state.dates : null;
    final shown = all?.take(kDatesPreview).toList();
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);
    final showAgent = seesAgencyDates(context);

    return AppCard(
      key: const ValueKey('dates-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.dashboardDatesTitle)),
              if (all != null && all.length > shown!.length)
                Flexible(
                  child: Text(l10n.dashboardDatesTotal(all.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: t.textSecondary)),
                ),
            ],
          ),
          const SizedBox(height: 11),
          if (state is ClientDatesError) ...[
            Text(l10n.clientsDatesLoadFailed,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
            const SizedBox(height: 10),
            AppGhostButton(
              key: const ValueKey('dates-retry'),
              label: l10n.coreRetry,
              onPressed: () =>
                  context.read<ClientDatesBloc>().add(ClientDatesLoadEvent()),
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ] else if (shown == null)
            const Column(children: [
              ClientDateRowBone(),
              SizedBox(height: 8),
              ClientDateRowBone(),
            ])
          else ...[
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              ClientDateRow(
                date: shown[i],
                nested: true,
                showAgent: showAgent,
                onTap: () => context.push('/clients/${shown[i].clientId}'),
                onCall: () => callClientDate(context, shown[i]),
                onGreet: () => greetClientDate(context, shown[i]),
              ),
            ],
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('dates-see-all'),
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
