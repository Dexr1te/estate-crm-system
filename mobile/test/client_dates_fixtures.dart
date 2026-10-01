import 'dart:async';

import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/client_dates_repository.dart';

/// Birthdays and anniversaries in memory. Kept beside the other client
/// fakes' file rather than in it, like the going-cold fixtures.
class FakeClientDatesRepository implements ClientDatesRepository {
  List<UpcomingClientDate> dates;

  /// When set, reading fails with it — the card's own error state.
  Object? readError;

  /// When set, a read waits for it — the skeleton stays up until then.
  Future<void>? hold;

  /// Every read, as `(from, days)`.
  final List<(DateTime, int)> queries = [];

  FakeClientDatesRepository([this.dates = const []]);

  @override
  Future<List<UpcomingClientDate>> getUpcoming({
    required DateTime from,
    int days = ClientDatesRepository.defaultDays,
  }) async {
    queries.add((from, days));
    if (hold != null) await hold;
    if (readError != null) throw readError!;
    return dates.where((d) => d.daysAway < days).toList();
  }
}

/// Wednesday 30 September 2026, ten in the morning.
final kDatesNow = DateTime(2026, 9, 30, 10);

UpcomingClientDate birthdayIn(int daysAway,
        {int clientId = 1,
        String name = 'Aigerim Bekova',
        int? years = 36,
        String? phone = '+7 701 111 22 33',
        String? agentName = 'Timur Aliev'}) =>
    UpcomingClientDate(
      kind: ClientDateKind.birthday,
      date: DateTime(2026, 9, 30 + daysAway),
      daysAway: daysAway,
      years: years,
      clientId: clientId,
      clientName: name,
      phone: phone,
      clientType: ClientType.BUYER,
      agentId: 7,
      agentName: agentName,
    );

UpcomingClientDate anniversaryIn(int daysAway,
        {int clientId = 2,
        String name = 'Bolat Seitkali',
        int years = 3,
        String dealTitle = 'Flat on Dostyk',
        String? propertyTitle = 'Dostyk 5, apt 12'}) =>
    UpcomingClientDate(
      kind: ClientDateKind.purchaseAnniversary,
      date: DateTime(2026, 9, 30 + daysAway),
      daysAway: daysAway,
      years: years,
      clientId: clientId,
      clientName: name,
      phone: '+7 702 222 33 44',
      clientType: ClientType.SELLER,
      agentId: 7,
      agentName: 'Timur Aliev',
      dealId: 40 + clientId,
      dealTitle: dealTitle,
      propertyTitle: propertyTitle,
    );
