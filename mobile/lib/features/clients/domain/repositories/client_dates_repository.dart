import 'package:real_estate_crm/core/models/models.dart';

/// Birthdays and purchase anniversaries coming up. An agent gets their own
/// clients' dates, a manager the agency's; the rule lives on the backend.
abstract class ClientDatesRepository {
  /// The full list on the "Dates coming up" screen.
  static const defaultDays = 14;

  /// The dashboard card: today and the rest of the week.
  static const weekDays = 7;

  /// Dates from [from] (the phone's today) for [days] days, soonest first.
  Future<List<UpcomingClientDate>> getUpcoming({
    required DateTime from,
    int days = defaultDays,
  });
}
