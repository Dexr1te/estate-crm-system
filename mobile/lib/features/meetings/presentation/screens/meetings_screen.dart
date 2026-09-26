import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/calendar_month_view.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/dashboard_hero.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/meeting_row.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MeetingsScreen extends StatefulWidget {
  final bool initialMonth;
  const MeetingsScreen({super.key, this.initialMonth = false});
  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  late bool _month = widget.initialMonth;

  @override
  void initState() {
    super.initState();
    context.read<MeetingsBloc>().add(MeetingsLoadEvent());
  }

  Future<void> _call(MeetingResponse meeting) async {
    final l10n = AppLocalizations.of(context);
    String? phone;
    try {
      phone =
          (await Injector.clientsRepository.getClient(meeting.clientId)).phone;
    } catch (_) {
      phone = null;
    }
    if (!mounted) return;
    if (!await ContactActions.call(phone) && mounted) {
      showActionUnavailable(context, l10n.clientsNoPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);
    final gap = AppMetrics.blockGap(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AppMetrics.constrain(
          _month
              ? Column(children: [
                  _header(l10n, pad, null),
                  const Expanded(child: CalendarMonthView()),
                ])
              : BlocConsumer<MeetingsBloc, MeetingsState>(
                  listener: (ctx, state) {
                    if (state is MeetingsError) {
                      ScaffoldMessenger.of(ctx)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(apiFailureLabel(l10n, state.failure)),
                            backgroundColor: t.dangerSolid));
                    }
                    showActionOutcome(ctx, state);
                  },
                  builder: (ctx, state) {
                    if (state is MeetingsLoading || state is MeetingsInitial) {
                      return _loadingLayout(l10n, pad, gap);
                    }
                    if (state is MeetingsError) {
                      return Column(children: [
                        _header(l10n, pad, null),
                        Expanded(
                          child: ErrorWidget2(
                            message: apiFailureLabel(l10n, state.failure),
                            onRetry: () => ctx
                                .read<MeetingsBloc>()
                                .add(MeetingsLoadEvent()),
                          ),
                        ),
                      ]);
                    }

                    final all = state is MeetingsLoaded
                        ? state.meetings
                        : <MeetingResponse>[];
                    final now = AppClock.now();
                    final upcoming = all
                        .where(
                            (m) => !m.completed && m.scheduledAt.isAfter(now))
                        .toList()
                      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
                    final next = upcoming.isEmpty ? null : upcoming.first;
                    final rest = upcoming.length < 2
                        ? const <MeetingResponse>[]
                        : upcoming.sublist(1);
                    final thisWeek = upcoming
                        .where((m) => m.scheduledAt.difference(now).inDays < 7)
                        .length;

                    if (all.isEmpty) {
                      return Column(children: [
                        _header(l10n, pad, l10n.meetingsCounter(0)),
                        Expanded(
                          child: EmptyState(
                            icon: Icons.event_available_outlined,
                            title: l10n.meetingsNoMeetings,
                            subtitle: l10n.meetingsScheduleFirst,
                          ),
                        ),
                      ]);
                    }

                    return RefreshIndicator(
                      onRefresh: () async =>
                          ctx.read<MeetingsBloc>().add(MeetingsLoadEvent()),
                      color: t.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _header(l10n, pad, l10n.meetingsCounter(thisWeek)),
                            Padding(
                              padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (next == null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: EmptyState(
                                        icon: Icons.event_available_outlined,
                                        title: l10n.meetingsNothingUpcoming,
                                        subtitle: l10n
                                            .meetingsNothingUpcomingSubtitle,
                                      ),
                                    ),
                                  if (next != null) ...[
                                    NextMeetingHero(
                                      meeting: next,
                                      eyebrow: l10n.meetingsUpcomingEyebrow,
                                      primaryLabel: l10n.coreOpen,
                                      onPrimary: () =>
                                          context.push('/meetings/${next.id}'),
                                      secondaryLabel: l10n.coreCall,
                                      onSecondary: () => _call(next),
                                    ),
                                    SizedBox(height: gap + 2),
                                  ],
                                  ..._groups(rest, now, l10n),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n, double pad, String? subtitle) =>
      Padding(
        padding: EdgeInsets.fromLTRB(pad, 10, pad, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                    child: ScreenTitle(l10n.calendarTitle,
                        subtitle: subtitle, reserveSubtitle: true)),
                const SizedBox(width: 12),
                AppHeaderAction(
                  label: l10n.meetingsAddShort,
                  onPressed: () => context.go('/meetings/new'),
                )
              ],
            ),
            const SizedBox(height: 12),
            SegmentedTabs(
              key: const ValueKey('calendar-view-tabs'),
              labels: [l10n.calendarViewList, l10n.calendarViewMonth],
              selectedIndex: _month ? 1 : 0,
              onSelected: (i) => setState(() => _month = i == 1),
            ),
          ],
        ),
      );

  Widget _loadingLayout(AppLocalizations l10n, double pad, double gap) =>
      Column(
        children: [
          _header(l10n, pad, null),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: ShimmerGroup(
                child: SingleChildScrollView(
                    child: Column(children: [
                  const ShimmerHeroCard(),
                  SizedBox(height: gap + 6),
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ShimmerBox(width: 92, height: 10, radius: 5),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(height: 9),
                    MeetingRowBone(
                      titleFactor: [0.7, 0.5, 0.62, 0.44][i],
                      metaFactor: [0.36, 0.46, 0.3, 0.4][i],
                    ),
                  ],
                ])),
              ),
            ),
          ),
        ],
      );

  List<Widget> _groups(
      List<MeetingResponse> meetings, DateTime now, AppLocalizations l10n) {
    if (meetings.isEmpty) return const [];
    final locale = Localizations.localeOf(context).toLanguageTag();

    final byDay = <DateTime, List<MeetingResponse>>{};
    for (final m in meetings) {
      final day =
          DateTime(m.scheduledAt.year, m.scheduledAt.month, m.scheduledAt.day);
      byDay.putIfAbsent(day, () => []).add(m);
    }
    final days = byDay.keys.toList()..sort();

    final out = <Widget>[];
    for (final day in days) {
      if (out.isNotEmpty) out.add(const SizedBox(height: 16));
      out.add(EyebrowLabel(
        _groupLabel(day, now, l10n, locale),
        color: context.tokens.textSecondary,
      ));
      out.add(const SizedBox(height: 10));
      final items = byDay[day]!;
      for (var i = 0; i < items.length; i++) {
        if (i > 0) out.add(const SizedBox(height: 9));
        final m = items[i];
        out.add(MeetingRow(
          time: formatTimeOfDay(m.scheduledAt),
          dayOrType: m.location ?? '',
          title: m.title,
          meta: m.clientName,
          onTap: () => context.push('/meetings/${m.id}'),
        ));
      }
    }
    return out;
  }

  String _groupLabel(
      DateTime day, DateTime now, AppLocalizations l10n, String locale) {
    if (isSameDay(day, now)) return l10n.meetingsGroupToday;
    if (isSameDay(day, now.add(const Duration(days: 1)))) {
      return '${l10n.meetingsGroupTomorrow}, ${formatDayMonth(day, locale)}';
    }
    return formatWeekdayDate(day, locale);
  }
}
