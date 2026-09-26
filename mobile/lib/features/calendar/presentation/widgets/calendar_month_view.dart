import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';
import 'package:real_estate_crm/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:real_estate_crm/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:real_estate_crm/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/calendar_header.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/create_from_day.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/day_agenda.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/month_grid.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_sheet.dart';

/// The week starts on Monday in Russian and Kazakh; English follows what the
/// locale's Material localizations say.
int calendarFirstDayOfWeek(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'ru' || code == 'kk') return 1;
  return MaterialLocalizations.of(context).firstDayOfWeekIndex;
}

class CalendarMonthView extends StatefulWidget {
  const CalendarMonthView({super.key});

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView> {
  CalendarBloc? _bloc;
  bool _collapsed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final first = calendarFirstDayOfWeek(context);
    if (_bloc?.firstDayOfWeekIndex == first) return;
    final previous = _bloc;
    _bloc = CalendarBloc(
      Injector.meetingsRepository,
      Injector.tasksRepository,
      firstDayOfWeekIndex: first,
    )..add(CalendarShowMonthEvent(previous?.state.month ?? AppClock.now()));
    previous?.close();
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  CalendarBloc get bloc => _bloc!;

  void _step(CalendarState state, int direction) {
    if (_collapsed) {
      final d = state.selectedDay;
      bloc.add(CalendarSelectDayEvent(
          DateTime(d.year, d.month, d.day + 7 * direction)));
    } else {
      bloc.add(CalendarShowMonthEvent(
          DateTime(state.month.year, state.month.month + direction)));
    }
  }

  Future<void> _create(DateTime day) async {
    bloc.add(CalendarSelectDayEvent(day));
    final kind = await showCreateFromDaySheet(context, day);
    if (kind == null || !mounted) return;
    switch (kind) {
      case CalendarCreateKind.meeting:
        await context.push('/meetings/new?date=${calendarDateParam(day)}');
        if (mounted) bloc.add(CalendarRefreshEvent());
      case CalendarCreateKind.task:
        await showTaskSheet(context, dueAt: taskDueOn(day, AppClock.now()));
    }
  }

  bool _canAdd(DateTime day, DateTime now) => !day.isBefore(dayOf(now));

  @override
  Widget build(BuildContext context) {
    final pad = AppMetrics.pagePadding(context);
    final gap = AppMetrics.blockGap(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<CalendarBloc, CalendarState>(
          bloc: bloc,
          listenWhen: (p, c) => c.outcome != null && p.outcome != c.outcome,
          listener: (ctx, state) => showActionOutcome(ctx, state.outcome),
        ),
        BlocListener<MeetingsBloc, MeetingsState>(
          listenWhen: (_, c) => c is MeetingsActionSuccess,
          listener: (_, __) => bloc.add(CalendarRefreshEvent()),
        ),
      ],
      child: BlocBuilder<CalendarBloc, CalendarState>(
        bloc: bloc,
        builder: (context, state) {
          final now = AppClock.now();
          final today = dayOf(now);
          final day = state.selectedDay;
          return RefreshIndicator(
            onRefresh: () async => bloc.add(CalendarRefreshEvent()),
            color: context.tokens.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
              children: [
                AppCard(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CalendarHeader(
                        month: _collapsed ? monthOf(day) : state.month,
                        collapsed: _collapsed,
                        onPrevious: () => _step(state, -1),
                        onNext: () => _step(state, 1),
                        onToggleCollapsed: () =>
                            setState(() => _collapsed = !_collapsed),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragEnd: (d) {
                          final v = d.primaryVelocity ?? 0;
                          if (v.abs() < 200) return;
                          _step(state, v < 0 ? 1 : -1);
                        },
                        child: MonthGrid(
                          month: state.month,
                          selectedDay: day,
                          now: now,
                          firstDayOfWeekIndex: bloc.firstDayOfWeekIndex,
                          collapsed: _collapsed,
                          page: state.page,
                          onTap: (d) => bloc.add(CalendarSelectDayEvent(d)),
                          onLongPress: (d) {
                            if (_canAdd(d, now)) _create(d);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: CalendarLegend(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: gap + 2),
                DayAgenda(
                  day: day,
                  now: now,
                  page: state.page,
                  failure: state.failure,
                  onRetry: () => bloc.add(CalendarRefreshEvent()),
                  onAdd: _canAdd(day, now) ? () => _create(day) : null,
                  onToday: isSameDay(day, today)
                      ? null
                      : () => bloc.add(CalendarSelectDayEvent(today)),
                  onOpenMeeting: (m) async {
                    await context.push('/meetings/${m.id}');
                    if (mounted) bloc.add(CalendarRefreshEvent());
                  },
                  onOpenTask: (task) => showTaskSheet(context, task: task),
                  onToggleTask: (task) =>
                      bloc.add(CalendarToggleTaskEvent(task)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
