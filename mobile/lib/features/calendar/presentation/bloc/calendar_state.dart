import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';

class CalendarState {
  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, CalendarPage> pages;
  final ApiFailure? failure;
  final ActionOutcome? outcome;

  const CalendarState({
    required this.month,
    required this.selectedDay,
    this.pages = const {},
    this.failure,
    this.outcome,
  });

  CalendarPage? get page => pages[month];

  bool get isLoading => page == null && failure == null;

  CalendarState copyWith({
    DateTime? month,
    DateTime? selectedDay,
    Map<DateTime, CalendarPage>? pages,
    ApiFailure? failure,
    bool clearFailure = false,
    ActionOutcome? outcome,
  }) =>
      CalendarState(
        month: month ?? this.month,
        selectedDay: selectedDay ?? this.selectedDay,
        pages: pages ?? this.pages,
        failure: clearFailure ? null : failure ?? this.failure,
        outcome: outcome,
      );
}

class CalendarActionDone with ActionSucceeded {
  @override
  final ActionMessage message;
  CalendarActionDone(this.message);
}

class CalendarActionFailed with ActionFailed {
  @override
  final ApiFailure failure;
  CalendarActionFailed(this.failure);
}
