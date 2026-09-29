import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/cold_client_actions.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/cold_client_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many clients going cold the dashboard shows before "See all".
const kGoingColdPreview = 3;

/// The clients going quiet, on the dashboard: the top few with a call and a
/// reminder each. Nothing at all when nobody is going cold, a skeleton while
/// it loads, and a failure stays inside the card.
///
/// [topGap] sits above the card and goes with it, so a hidden card leaves no
/// hole in the column.
class GoingColdCard extends StatefulWidget {
  final VoidCallback onSeeAll;
  final double topGap;

  /// The total from the dashboard summary, when it is known.
  final int? total;

  const GoingColdCard({
    super.key,
    required this.onSeeAll,
    this.topGap = 0,
    this.total,
  });

  @override
  State<GoingColdCard> createState() => _GoingColdCardState();
}

class _GoingColdCardState extends State<GoingColdCard>
    with ColdClientActions<GoingColdCard> {
  @override
  ColdClientsBloc get coldBloc => context.read<ColdClientsBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ColdClientsBloc, ColdClientsState>(
      listener: onColdState,
      builder: (context, state) {
        if (state is ColdClientsLoaded && state.clients.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('going-cold-hidden'));
        }
        return Padding(
          padding: EdgeInsets.only(top: widget.topGap),
          child: _card(context, state),
        );
      },
    );
  }

  Widget _card(BuildContext context, ColdClientsState state) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final shown = state is ColdClientsLoaded
        ? state.clients.take(kGoingColdPreview).toList()
        : null;
    final total = widget.total ??
        (state is ColdClientsLoaded ? state.clients.length : null);
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);

    return AppCard(
      key: const ValueKey('going-cold-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.clientsColdTitle)),
              if (total != null && shown != null && total > shown.length)
                Flexible(
                  child: Text(l10n.dashboardColdTotal(total),
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
          if (state is ColdClientsError) ...[
            Text(l10n.clientsColdLoadFailed,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
            const SizedBox(height: 10),
            AppGhostButton(
              key: const ValueKey('going-cold-retry'),
              label: l10n.coreRetry,
              onPressed: () => coldBloc.add(ColdClientsLoadEvent()),
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ] else if (shown == null)
            const Column(children: [
              ColdClientRowBone(),
              SizedBox(height: 8),
              ColdClientRowBone(),
            ])
          else ...[
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              ColdClientRow(
                client: shown[i],
                nested: true,
                showNextStep: false,
                onTap: () => context.push('/clients/${shown[i].id}'),
                onCall: () => callCold(shown[i]),
                onRemind: () => remindCold(shown[i]),
              ),
            ],
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('going-cold-see-all'),
              label: l10n.dashboardSeeAll,
              onPressed: widget.onSeeAll,
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ],
        ],
      ),
    );
  }
}
