import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_board.dart';
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

  /// The same deals, read either as one list under a stage filter or as the
  /// pipeline with a column per stage. The board is the only place a deal can
  /// be moved by hand, so it owns the drag; the list stays a list.
  bool _board = false;
  PageController? _pageCtrl;
  int _page = 0;

  /// Stages a drop has asked for but the server has not confirmed yet. Without
  /// them the card sits in its old column until the reload lands, which reads
  /// as the drag having failed.
  final _pending = <int, DealStatus>{};

  @override
  void initState() {
    super.initState();
    _filter = widget.initialStatus;
    context.read<DealsBloc>().add(DealsLoadEvent());
  }

  @override
  void dispose() {
    _pageCtrl?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DealsScreen old) {
    super.didUpdateWidget(old);
    if (old.initialStatus != widget.initialStatus) {
      setState(() => _filter = widget.initialStatus);
      if (_board) _goToPage(_pageOf(widget.initialStatus));
    }
  }

  int _pageOf(DealStatus? status) =>
      status == null ? 0 : DealStatus.values.indexOf(status);

  void _goToPage(int i) {
    setState(() => _page = i);
    if (_pageCtrl?.hasClients ?? false) {
      _pageCtrl!.animateToPage(i,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic);
    }
  }

  void _toggleView() {
    setState(() {
      _board = !_board;
      if (!_board) return;
      // Carry the stage the list was filtered to over to the board, so the
      // toggle never lands on a column you were not already looking at.
      _page = _pageOf(_filter);
      _pageCtrl?.dispose();
      _pageCtrl = PageController(initialPage: _page);
    });
  }

  void _move(DealResponse deal, DealStatus to) {
    if (deal.status == to) return;
    setState(() => _pending[deal.id] = to);
    context.read<DealsBloc>().add(DealsUpdateStatusEvent(deal.id, to));
  }

  List<DealResponse> _withPending(List<DealResponse> deals) {
    if (_pending.isEmpty) return deals;
    return [
      for (final d in deals)
        _pending.containsKey(d.id) ? d.copyWith(status: _pending[d.id]!) : d,
    ];
  }

  /// Whether [state] is the answer a pending move was waiting for. The success
  /// state still carries the rows from before the write, so dropping the guess
  /// on it would snap the card back for the frame before the reload arrives.
  static bool _settles(DealsState state) =>
      state is DealsError ||
      state is DealsActionFailure ||
      (state is DealsLoaded && state is! ActionOutcome);

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
              if (_pending.isNotEmpty && _settles(state)) {
                setState(_pending.clear);
              }
              showActionOutcome(ctx, state);
            },
            builder: (ctx, state) {
              final all = _withPending(
                  state is DealsLoaded ? state.deals : const <DealResponse>[]);
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
                            const SizedBox(width: 8),
                            AppIconTile(
                              icon: _board
                                  ? Icons.view_agenda_outlined
                                  : Icons.view_kanban_outlined,
                              tooltip: _board
                                  ? l10n.dealsViewList
                                  : l10n.dealsViewBoard,
                              onPressed: _toggleView,
                            ),
                            const SizedBox(width: 4),
                            AppHeaderAction(
                              label: l10n.dealsAddShort,
                              onPressed: () => context.go('/deals/new'),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),
                        // On the board the stages are the columns, so the same
                        // row of pills steers the pages instead of filtering.
                        FilterPillRow(
                            pills: _board
                                ? _stagePills(l10n, all)
                                : _filterPills(l10n, all)),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _board
                        ? _boardBody(ctx, state, all, l10n, pad)
                        : _body(ctx, state, visible, l10n, pad),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _filterPills(AppLocalizations l10n, List<DealResponse> all) => [
        FilterPill(
          label: l10n.dealsFilterWithCount(all.length, l10n.dealsFilterAll),
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
      ];

  List<Widget> _stagePills(AppLocalizations l10n, List<DealResponse> all) => [
        for (var i = 0; i < DealStatus.values.length; i++)
          FilterPill(
            label: l10n.dealsFilterWithCount(
                all.where((d) => d.status == DealStatus.values[i]).length,
                dealStatusLabel(l10n, DealStatus.values[i])),
            selected: _page == i,
            onTap: () => _goToPage(i),
          ),
      ];

  Widget _boardBody(BuildContext ctx, DealsState state, List<DealResponse> all,
      AppLocalizations l10n, double pad) {
    final placeholder = _placeholder(ctx, state, all, l10n, pad);
    if (placeholder != null) return placeholder;

    return DealBoard(
      deals: all,
      controller: _pageCtrl!,
      padding: pad,
      onPageChanged: (i) => setState(() => _page = i),
      onMove: _move,
      onOpen: (deal) => ctx.go('/deals/${deal.id}'),
      onRefresh: () async => ctx.read<DealsBloc>().add(DealsLoadEvent()),
    );
  }

  Widget _body(BuildContext ctx, DealsState state, List<DealResponse> visible,
      AppLocalizations l10n, double pad) {
    final placeholder = _placeholder(ctx, state, visible, l10n, pad);
    if (placeholder != null) return placeholder;

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

  /// What stands in for the deals when there are none to draw — the same
  /// skeleton, error and empty screens whichever view is showing.
  Widget? _placeholder(BuildContext ctx, DealsState state,
      List<DealResponse> shown, AppLocalizations l10n, double pad) {
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
    if (shown.isEmpty) {
      // An empty stage on the board is the column's own business — the board
      // only gives up when the whole pipeline is empty.
      final filtered = !_board && _filter != null;
      return EmptyState(
        icon: Icons.handshake_outlined,
        title: filtered ? l10n.dealsNoResults : l10n.dealsEmptyTitle,
        subtitle:
            filtered ? l10n.dealsNoResultsSubtitle : l10n.dealsEmptySubtitle,
      );
    }
    return null;
  }
}
