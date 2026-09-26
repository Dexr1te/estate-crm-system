import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';
import 'package:real_estate_crm/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:real_estate_crm/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState>
    with SingleFlight {
  final MeetingsRepository _meetings;
  final TasksRepository _tasks;
  final int firstDayOfWeekIndex;
  final _tickets = <DateTime, int>{};
  late final StreamSubscription<void> _changes;

  CalendarBloc(this._meetings, this._tasks, {required this.firstDayOfWeekIndex})
      : super(CalendarState(
          month: monthOf(AppClock.now()),
          selectedDay: dayOf(AppClock.now()),
        )) {
    on<CalendarShowMonthEvent>(_onShowMonth);
    on<CalendarSelectDayEvent>(_onSelectDay);
    on<CalendarRefreshEvent>(_onRefresh);
    on<CalendarToggleTaskEvent>(_onToggle);
    _changes = _tasks.changes.listen((_) {
      if (!isClosed) add(CalendarRefreshEvent());
    });
  }

  Future<void> _onShowMonth(
      CalendarShowMonthEvent e, Emitter<CalendarState> emit) async {
    final month = monthOf(e.month);
    final today = dayOf(AppClock.now());
    final selected = monthOf(today) == month
        ? today
        : monthOf(state.selectedDay) == month
            ? state.selectedDay
            : month;
    emit(state.copyWith(
        month: month, selectedDay: selected, clearFailure: true));
    if (!state.pages.containsKey(month)) await _fetch(emit, month);
  }

  Future<void> _onSelectDay(
      CalendarSelectDayEvent e, Emitter<CalendarState> emit) async {
    final day = dayOf(e.day);
    final month = monthOf(day);
    final moved = month != state.month;
    emit(state.copyWith(
        month: month, selectedDay: day, clearFailure: moved ? true : false));
    if (moved && !state.pages.containsKey(month)) await _fetch(emit, month);
  }

  Future<void> _onRefresh(
      CalendarRefreshEvent e, Emitter<CalendarState> emit) async {
    final current = state.pages[state.month];
    emit(state.copyWith(
      pages: {if (current != null) state.month: current},
      clearFailure: true,
    ));
    await _fetch(emit, state.month);
  }

  Future<void> _fetch(Emitter<CalendarState> emit, DateTime month) async {
    final ticket = (_tickets[month] ?? 0) + 1;
    _tickets[month] = ticket;
    final (from, to) = monthGridRange(month, firstDayOfWeekIndex);
    try {
      final read = await Future.wait<List<Object>>([
        _meetings.getMeetingsBetween(from, to),
        _tasks.getTasks(TaskQuery(includeDone: true, from: from, to: to)),
      ]);
      final page = CalendarPage(
        meetings: read[0].cast<MeetingResponse>(),
        tasks: read[1].cast<TaskResponse>(),
      );
      if (isClosed || _tickets[month] != ticket) return;
      emit(state.copyWith(pages: {...state.pages, month: page}));
    } catch (err) {
      if (isClosed || _tickets[month] != ticket) return;
      final failure = ApiFailure.from(err);
      if (month == state.month && state.page == null) {
        emit(state.copyWith(failure: failure));
      } else if (month == state.month) {
        emit(state.copyWith(outcome: CalendarActionFailed(failure)));
      }
    }
  }

  Future<void> _onToggle(
          CalendarToggleTaskEvent e, Emitter<CalendarState> emit) =>
      once('toggle-${e.task.id}', () async {
        final done = e.task.isDone;
        try {
          final updated = done
              ? await _tasks.reopenTask(e.task.id)
              : await _tasks.completeTask(e.task.id);
          emit(state.copyWith(
            pages: state.pages.map(
                (month, page) => MapEntry(month, page.replaceTask(updated))),
            outcome: CalendarActionDone(done
                ? ActionMessage.taskReopened
                : ActionMessage.taskCompleted),
          ));
        } catch (err) {
          emit(state.copyWith(
              outcome: CalendarActionFailed(ApiFailure.from(err))));
        }
      });

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
