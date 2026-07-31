import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/dashboard_hero.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/meeting_row.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/pipeline_card.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/conversion_card.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/meeting_load_card.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/stage_value_card.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/top_agents_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many rows the "upcoming" list shows before deferring to the meetings
/// screen.
const _kUpcomingPreviewCount = 4;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadEvent());
  }

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 5) return l10n.dashboardGreetingStillUp;
    if (h < 12) return l10n.dashboardGreetingMorning;
    if (h < 18) return l10n.dashboardGreetingAfternoon;
    return l10n.dashboardGreetingEvening;
  }

  Future<void> _call(MeetingResponse meeting) async {
    final l10n = AppLocalizations.of(context);
    String? phone;
    try {
      phone = (await Injector.clientsRepository.getClient(meeting.clientId))
          .phone;
    } catch (_) {
      phone = null;
    }
    if (!mounted) return;
    if (!await ContactActions.call(phone)) {
      if (!mounted) return;
      showActionUnavailable(context, l10n.dashboardNoPhone);
    }
  }

  void _openMeeting(MeetingResponse meeting) {
    // The deal is the richer destination when the meeting is attached to one.
    if (meeting.dealId != null) {
      context.push('/deals/${meeting.dealId}');
    } else {
      context.go('/meetings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);
    final gap = AppMetrics.blockGap(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (ctx, state) => RefreshIndicator(
            onRefresh: () async =>
                ctx.read<DashboardBloc>().add(DashboardLoadEvent()),
            color: t.primary,
            child: AppMetrics.constrain(
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(pad, 6, pad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingRow(
                      title: l10n.dashboardGreeting(
                        _greeting(l10n),
                        user?.fullName.split(' ').first ??
                            l10n.dashboardGreetingFallbackName,
                      ),
                      subtitle: l10n.dashboardDateSummary(formatWeekdayDate(
                          DateTime.now(),
                          Localizations.localeOf(context).toLanguageTag())),
                      initial: user?.fullName ?? '',
                      onTap: () => context.push('/profile'),
                    ),
                    const SizedBox(height: 18),
                    if (state is DashboardLoading)
                      const _DashboardSkeleton()
                    else if (state is DashboardError)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: ErrorWidget2(
                          message: state.message,
                          onRetry: () =>
                              ctx.read<DashboardBloc>().add(DashboardLoadEvent()),
                        ),
                      )
                    else if (state is DashboardLoaded)
                      ..._loaded(context, state, l10n, gap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _loaded(BuildContext context, DashboardLoaded state,
      AppLocalizations l10n, double gap) {
    final now = DateTime.now();
    final next = state.nextMeeting;
    final pipeline = PipelineBreakdown.from(state.deals);
    final todayCount = state.meetingsToday(now);
    final agents = state.topAgents();
    final later = state.laterMeetings.take(_kUpcomingPreviewCount).toList();
    final locale = Localizations.localeOf(context).toLanguageTag();

    void openStage(DealStatus status) =>
        context.go('/deals?status=${status.name}');

    return [
      // The hero used to disappear entirely with nothing scheduled, which left
      // the top of the screen empty and made the dashboard look broken.
      if (next != null)
        NextMeetingHero(
          meeting: next,
          eyebrow: l10n.dashboardNextMeeting,
          primaryLabel: l10n.coreOpen,
          onPrimary: () => _openMeeting(next),
          secondaryLabel: l10n.coreCall,
          onSecondary: () => _call(next),
        )
      else
        _ZeroCard(
          icon: Icons.event_available_outlined,
          title: l10n.dashboardNothingScheduled,
          hint: l10n.dashboardNothingScheduledHint,
          actionLabel: l10n.dashboardScheduleMeeting,
          onAction: () => context.go('/meetings/new'),
        ),
      SizedBox(height: gap),
      MetricsCard(metrics: [
        Metric(
          value: '${state.summary.activeDeals}',
          caption: l10n.dashboardActiveDealsLabel,
          onTap: () => context.go('/deals'),
        ),
        Metric(
          value: '${state.summary.totalClients}',
          caption: l10n.dashboardClients,
          onTap: () => context.go('/clients'),
        ),
        Metric(
          value: '${state.summary.closedDeals}',
          caption: l10n.dashboardClosedWon,
          onTap: () => context.go('/deals?status=CLOSED_WON'),
        ),
        Metric(
          value: '${state.summary.upcomingMeetings}',
          caption: l10n.dashboardMeetingsLabel,
          delta: todayCount > 0 ? l10n.dashboardTodayCount(todayCount) : null,
          // Not AppColors.warning: raw amber is ~2:1 on the light background
          // at this size. `statusText` keeps the hue and fixes the contrast.
          deltaColor: context.tokens.statusText(StatusHue.negotiation),
          onTap: () => context.go('/meetings'),
        ),
      ]),
      SizedBox(height: gap),
      // Also no longer conditional: an empty pipeline is information, and
      // hiding the card left a hole where the chart should be.
      if (pipeline.isEmpty)
        _ZeroCard(
          icon: Icons.handshake_outlined,
          title: l10n.dashboardNoDealsYet,
          hint: l10n.dashboardNoDealsYetHint,
          actionLabel: l10n.dashboardNewDeal,
          onAction: () => context.go('/deals/new'),
        )
      else ...[
        PipelineCard(pipeline: pipeline, onStageTap: openStage),
        SizedBox(height: gap),
        StageValueCard(pipeline: pipeline, onStageTap: openStage),
        SizedBox(height: gap),
        ConversionCard(pipeline: pipeline, onStageTap: openStage),
        if (context.isAdminOrManager && agents.isNotEmpty) ...[
          SizedBox(height: gap),
          TopAgentsCard(agents: agents),
        ],
      ],
      SizedBox(height: gap),
      MeetingLoadCard(
        load: state.meetingLoad(now),
        today: now,
        onTap: () => context.go('/meetings'),
      ),
      SizedBox(height: gap + 4),
      SectionHeader(
        title: l10n.dashboardUpcomingMeetings,
        actionLabel: l10n.dashboardSeeAll,
        onAction: () => context.go('/meetings'),
      ),
      const SizedBox(height: 10),
      if (later.isEmpty)
        _NoMoreMeetings(
          message: next == null
              ? l10n.dashboardNoUpcomingMeetings
              : l10n.dashboardNoMoreMeetingsToday,
        )
      else
        for (final m in later) ...[
          MeetingRow(
            time: formatTimeOfDay(m.scheduledAt),
            dayOrType: dayLabel(l10n, m.scheduledAt, now, locale),
            title: m.title,
            meta: m.clientName,
            onTap: () => _openMeeting(m),
          ),
          if (m != later.last) const SizedBox(height: 8),
        ],
    ];
  }
}

// ─── Greeting ────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String initial;
  final VoidCallback onTap;

  const _GreetingRow({
    required this.title,
    required this.subtitle,
    required this.initial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: t.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    color: t.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        UserAvatar(name: initial, size: 44, onTap: onTap),
      ],
    );
  }
}

// ─── Inline zero state ───────────────────────────────────────────

/// Stands in for a card whose data is empty, so the slot keeps its shape and
/// offers the action that would fill it — rather than vanishing and leaving
/// the dashboard looking half-loaded.
class _ZeroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final String actionLabel;
  final VoidCallback onAction;

  const _ZeroCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: t.textSecondary),
              ),
              const SizedBox(width: 11),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11.5,
                          height: 1.35,
                          color: t.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppGhostButton(
            label: actionLabel,
            onPressed: onAction,
            height: AppMetrics.buttonHeightInline,
          ),
        ],
      ),
    );
  }
}

// ─── Empty state for the schedule list ───────────────────────────

class _NoMoreMeetings extends StatelessWidget {
  final String message;
  const _NoMoreMeetings({required this.message});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary),
        ),
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final gap = AppMetrics.blockGap(context);

    return ShimmerGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
              width: double.infinity, height: 150, radius: AppMetrics.radiusLg),
          SizedBox(height: gap),
          const ShimmerBox(
              width: double.infinity, height: 148, radius: AppMetrics.radiusMd),
          SizedBox(height: gap),
          const ShimmerBox(
              width: double.infinity, height: 108, radius: AppMetrics.radiusMd),
          SizedBox(height: gap + 4),
          const ShimmerBox(width: 150, height: 14, radius: 7),
          const SizedBox(height: 10),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            const ShimmerBox(width: double.infinity, height: 62, radius: 14),
          ],
        ],
      ),
    );
  }
}
