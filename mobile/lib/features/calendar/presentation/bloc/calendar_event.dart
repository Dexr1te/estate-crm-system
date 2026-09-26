import 'package:real_estate_crm/core/models/models.dart';

abstract class CalendarEvent {}

class CalendarShowMonthEvent extends CalendarEvent {
  final DateTime month;
  CalendarShowMonthEvent(this.month);
}

class CalendarSelectDayEvent extends CalendarEvent {
  final DateTime day;
  CalendarSelectDayEvent(this.day);
}

class CalendarRefreshEvent extends CalendarEvent {}

class CalendarToggleTaskEvent extends CalendarEvent {
  final TaskResponse task;
  CalendarToggleTaskEvent(this.task);
}
