import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/split_labels.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_state.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/widgets/leaderboard_row_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How each agent in the manager's agency did over a period, ranked.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _bloc = LeaderboardBloc(Injector.leaderboardRepository)
    ..add(LeaderboardLoadEvent());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _pickRange(LeaderboardRange current) async {
    final l10n = AppLocalizations.of(context);
    final now = AppClock.now();
    final last = DateTime(now.year + 1, 12, 31);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: last,
      initialDateRange: DateTimeRange(
        start: current.from,
        end: current.lastDay.isAfter(last) ? last : current.lastDay,
      ),
      helpText: l10n.leaderboardPickRange,
    );
    if (picked == null || !mounted) return;
    _bloc.add(LeaderboardCustomRange(picked.start, picked.end));
  }

  String _rangeLabel(LeaderboardRange range) {
    final locale = Localizations.localeOf(context).toString();
    return AppLocalizations.of(context).leaderboardRange(
      formatFullDate(range.from, locale),
      formatFullDate(range.lastDay, locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      bloc: _bloc,
      builder: (context, state) => DetailScaffold(
        title: l10n.leaderboardTitle,
        onRefresh: () async => _bloc.add(LeaderboardLoadEvent()),
        children: [
          SegmentedTabs(
            labels: [
              l10n.leaderboardPeriodThisMonth,
              l10n.leaderboardPeriodLastMonth,
              l10n.leaderboardPeriodQuarter,
              l10n.leaderboardPeriodCustom,
            ],
            selectedIndex: state.period.index,
            onSelected: (i) {
              final period = LeaderboardPeriod.values[i];
              if (period == LeaderboardPeriod.custom) {
                _pickRange(state.range);
              } else {
                _bloc.add(LeaderboardPeriodChanged(period));
              }
            },
          ),
          Text(
            _rangeLabel(state.range),
            key: const ValueKey('leaderboard-range'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary),
          ),
          FilterPillRow(pills: [
            for (final sort in LeaderboardSort.values)
              FilterPill(
                key: ValueKey('leaderboard-sort-${sort.name}'),
                label: _sortLabel(l10n, sort, state),
                selected: state.sort == sort,
                onTap: () => _bloc.add(LeaderboardSortChanged(sort)),
              ),
          ]),
          ..._body(state, l10n),
        ],
      ),
    );
  }

  static String _sortLabel(
      AppLocalizations l10n, LeaderboardSort sort, LeaderboardState state) {
    final label = switch (sort) {
      LeaderboardSort.commission => l10n.leaderboardSortCommission,
      LeaderboardSort.dealsWon => l10n.leaderboardSortDealsWon,
      LeaderboardSort.viewings => l10n.leaderboardSortViewings,
      LeaderboardSort.newClients => l10n.leaderboardSortNewClients,
      LeaderboardSort.winRate => l10n.leaderboardSortWinRate,
    };
    if (state.sort != sort) return label;
    return '$label ${state.ascending ? '↑' : '↓'}';
  }

  List<Widget> _body(LeaderboardState state, AppLocalizations l10n) {
    if (state is LeaderboardError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.leaderboardLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(LeaderboardLoadEvent())),
        ),
      ];
    }
    if (state is! LeaderboardLoaded) {
      return [
        const ShimmerGroup(child: ShimmerMetricsCard(rows: 1)),
        for (var i = 0; i < 3; i++) const ShimmerGroup(child: _RowBones()),
      ];
    }
    final board = state.board;
    final agents = state.agents;
    final inactive = state.inactive;
    if (agents.isEmpty && inactive.isEmpty) {
      return [
        EmptyState(
          icon: Icons.leaderboard_outlined,
          title: l10n.leaderboardEmptyTitle,
          subtitle: l10n.leaderboardEmptyBody,
        ),
      ];
    }
    final totals = board.totals ?? const LeaderboardRow();
    final period = _rangeLabel(state.range);
    void open(LeaderboardRow row) => showLeaderboardAgentSheet(context,
        row: row, currency: board.currency, period: period);

    return [
      MetricsCard(metrics: [
        Metric(
          value: leaderboardMoney(totals.commission, board.currency),
          caption: l10n.leaderboardTeamCommission,
        ),
        Metric(
          value: '${totals.dealsWon}',
          caption: l10n.leaderboardSortDealsWon,
        ),
        Metric(
          value: leaderboardPercent(totals.winRate, l10n.leaderboardNoValue),
          caption: l10n.leaderboardSortWinRate,
        ),
      ]),
      const CommissionShareNote(),
      for (final row in agents)
        LeaderboardRowCard(
          row: row,
          sort: state.sort,
          currency: board.currency,
          onTap: () => open(row),
        ),
      if (inactive.isNotEmpty) ...[
        SectionHeader(title: l10n.leaderboardInactive, count: inactive.length),
        Text(
          l10n.leaderboardInactiveNote,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12,
              height: 1.4,
              color: context.tokens.textSecondary),
        ),
        for (final row in inactive)
          LeaderboardRowCard(
            row: row,
            sort: state.sort,
            currency: board.currency,
            muted: true,
            onTap: () => open(row),
          ),
      ],
    ];
  }
}

class _RowBones extends StatelessWidget {
  const _RowBones();

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.all(AppMetrics.cardPadding(context)),
        child: const Row(
          children: [
            ShimmerBox(width: 36, height: 36, radius: 18),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBar(widthFactor: 0.6),
                  SizedBox(height: 7),
                  ShimmerBar(widthFactor: 0.9, height: 8),
                ],
              ),
            ),
          ],
        ),
      );
}
