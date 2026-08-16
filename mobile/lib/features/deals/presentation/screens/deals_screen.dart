import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DealsScreen extends StatefulWidget {
  final DealStatus? initialStatus;

  const DealsScreen({super.key, this.initialStatus});

  static DealStatus? parseStatus(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final s in DealStatus.values) {
      if (s.name == raw) return s;
    }
    return null;
  }

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  DealStatus? _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialStatus;
    context.read<DealsBloc>().add(DealsLoadEvent());
  }

  @override
  void didUpdateWidget(covariant DealsScreen old) {
    super.didUpdateWidget(old);
    if (old.initialStatus != widget.initialStatus) {
      setState(() => _filter = widget.initialStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AppMetrics.constrain(
          BlocConsumer<DealsBloc, DealsState>(
            listener: (ctx, state) {
              if (state is DealsError) {
                ScaffoldMessenger.of(ctx)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(apiFailureLabel(l10n, state.failure)),
                      backgroundColor: t.dangerSolid));
              }
              showActionOutcome(ctx, state);
            },
            builder: (ctx, state) {
              final all = state is DealsLoaded ? state.deals : <DealResponse>[];
              final visible = _filter == null
                  ? all
                  : all.where((d) => d.status == _filter).toList();
              final totalValue = all.fold<double>(
                  0, (sum, d) => sum + (d.dealPrice ?? d.budget ?? 0));
              final active = all
                  .where((d) =>
                      d.status == DealStatus.LEAD ||
                      d.status == DealStatus.NEGOTIATION)
                  .length;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ScreenTitle(
                                l10n.dealsTitle,
                                reserveSubtitle: true,
                                subtitle: state is DealsLoaded
                                    ? l10n.dealsCounter(
                                        active, formatPrice(totalValue))
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AppHeaderAction(
                              label: l10n.dealsAddShort,
                              onPressed: () => context.go('/deals/new'),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),
                        FilterPillRow(pills: [
                          FilterPill(
                            label: l10n.dealsFilterWithCount(
                                all.length, l10n.dealsFilterAll),
                            selected: _filter == null,
                            onTap: () => setState(() => _filter = null),
                          ),
                          for (final s in DealStatus.values)
                            FilterPill(
                              label: l10n.dealsFilterWithCount(
                                  all.where((d) => d.status == s).length,
                                  dealStatusLabel(l10n, s)),
                              selected: _filter == s,
                              onTap: () => setState(() => _filter = s),
                            ),
                        ]),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  Expanded(child: _body(ctx, state, visible, l10n, pad)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext ctx, DealsState state, List<DealResponse> visible,
      AppLocalizations l10n, double pad) {
    if (state is DealsLoading || state is DealsInitial) {
      return ShimmerList(
        count: 4,
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        cardBuilder: () => const DealCardBone(),
      );
    }
    if (state is DealsError) {
      return ErrorWidget2(
        message: apiFailureLabel(l10n, state.failure),
        onRetry: () => ctx.read<DealsBloc>().add(DealsLoadEvent()),
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.handshake_outlined,
        title: _filter == null ? l10n.dealsEmptyTitle : l10n.dealsNoResults,
        subtitle: _filter == null
            ? l10n.dealsEmptySubtitle
            : l10n.dealsNoResultsSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ctx.read<DealsBloc>().add(DealsLoadEvent()),
      color: ctx.tokens.primary,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (_, i) => DealCard(
          deal: visible[i],
          onTap: () => context.go('/deals/${visible[i].id}'),
        ),
      ),
    );
  }
}
