import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';

abstract class TimeOffRepository {
  /// The agency's time off taking in any day of [from]..[to], soonest
  /// first; one person's with [userId]. Everybody in the agency sees it.
  Future<List<TimeOff>> getTimeOff(
      {required DateTime from, required DateTime to, int? userId});

  /// One absence, with the meetings that clash with it.
  Future<TimeOff> getOne(int id);

  Future<TimeOff> create(TimeOffDraft draft);

  Future<TimeOff> update(int id, TimeOffDraft draft);

  Future<void> cancel(int id);
}
