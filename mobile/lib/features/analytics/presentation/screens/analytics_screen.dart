import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:real_estate_crm/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:real_estate_crm/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/funnel_card.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/lost_reasons_card.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/monthly_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _bloc = AnalyticsBloc(Injector.analyticsRepository)
    ..add(AnalyticsLoadEvent());
  PickerItem? _agent;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _pickAgent() async {
    final l10n = AppLocalizations.of(context);
    List<AgentOption> agents;
    try {
      agents = await Injector.agentsRepository.getAgentOptions();
    } catch (_) {
      agents = const [];
    }
    if (!mounted) return;
    final picked = await showEntityPicker(
      context,
      title: l10n.analyticsSelectAgent,
      items: [
        PickerItem(id: 0, title: l10n.analyticsAllAgents),
        for (final a in agents)
          PickerItem(id: a.id, title: a.fullName, subtitle: a.email),
      ],
      selectedId: _agent?.id ?? 0,
      searchHint: l10n.dealsSearchHint,
      emptyLabel: l10n.coreNoResults,
    );
    if (picked == null || !mounted) return;
    setState(() => _agent = picked.id == 0 ? null : picked);
    _bloc.add(AnalyticsAgentChanged(_agent?.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      bloc: _bloc,
      builder: (context, state) => DetailScaffold(
        title: l10n.analyticsTitle,
        onRefresh: () async => _bloc.add(AnalyticsLoadEvent()),
        children: [
          SegmentedTabs(
            labels: [
              l10n.analyticsPeriodMonth,
              l10n.analyticsPeriodQuarter,
              l10n.analyticsPeriodYear,
            ],
            selectedIndex: state.period.index,
            onSelected: (i) =>
                _bloc.add(AnalyticsPeriodChanged(AnalyticsPeriod.values[i])),
          ),
          if (context.isAdminOrManager)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilterPill(
                key: const ValueKey('analytics-agent'),
                label: l10n
                    .analyticsAgent(_agent?.title ?? l10n.analyticsAllAgents),
                selected: _agent != null,
                onTap: _pickAgent,
              ),
            ),
          ..._body(state, l10n),
        ],
      ),
    );
  }

  List<Widget> _body(AnalyticsState state, AppLocalizations l10n) {
    if (state is AnalyticsError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.analyticsLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(AnalyticsLoadEvent())),
        ),
      ];
    }
    if (state is! AnalyticsLoaded) {
      return const [
        ShimmerGroup(child: ShimmerMetricsCard(rows: 1)),
        ShimmerGroup(child: _ChartBones(rows: 3)),
        ShimmerGroup(child: _ChartBones(rows: 2)),
      ];
    }
    final f = state.funnel;
    final hasHistory =
        f.monthly.any((m) => m.created > 0 || m.won > 0 || m.lost > 0);
    if (f.created == 0) {
      return [
        EmptyState(
          icon: Icons.insights_outlined,
          title: l10n.analyticsEmptyTitle,
          subtitle: l10n.analyticsEmptyBody,
        ),
        if (hasHistory) MonthlyCard(months: f.monthly),
      ];
    }
    final days = f.avgDaysToWin;
    return [
      MetricsCard(metrics: [
        Metric(value: formatPrice(f.wonValue), caption: l10n.analyticsWonValue),
        Metric(
          value: days == null
              ? l10n.analyticsNoValue
              : l10n.analyticsDays(_days(days)),
          caption: l10n.analyticsAvgDaysToWin,
        ),
      ]),
      FunnelCard(funnel: f),
      LostReasonsCard(reasons: f.lostReasons),
      MonthlyCard(months: f.monthly),
    ];
  }

  static String _days(double days) => days == days.roundToDouble()
      ? days.toStringAsFixed(0)
      : days.toStringAsFixed(1);
}

class _ChartBones extends StatelessWidget {
  final int rows;
  const _ChartBones({required this.rows});

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.all(AppMetrics.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShimmerBar(widthFactor: 0.3, height: 9),
            for (var i = 0; i < rows; i++) ...[
              const SizedBox(height: 16),
              const ShimmerBar(widthFactor: 0.5),
              const SizedBox(height: 7),
              ShimmerBar(widthFactor: 0.9 - i * 0.25, height: 8),
            ],
          ],
        ),
      );
}
