import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/models/models.dart';

/// Friday 9 October 2026, ten in the morning.
final keysNow = DateTime(2026, 10, 9, 10, 0);

DateTime keyDay(int days) =>
    DateTime(keysNow.year, keysNow.month, keysNow.day + days);

DateTime keyMoment(int days, {int hour = 11}) =>
    DateTime(keysNow.year, keysNow.month, keysNow.day + days, hour);

/// The agency, as the agent picker lists it.
const keysAgents = [
  AgentOption(id: 1, fullName: 'Asel Nurlanovna'),
  AgentOption(id: 2, fullName: 'Aigul Bekova'),
  AgentOption(id: 3, fullName: 'Timur Aliev'),
];

KeyHandover keyHandover({
  required int id,
  int propertyId = 1,
  String? propertyTitle,
  String? propertyAddress,
  String? propertyCity,
  int? holderUserId,
  required String holderName,
  String? note,
  int outDaysAgo = 2,
  DateTime? dueBackAt,
  DateTime? returnedAt,
  String? handedOutByName = 'Aigul Bekova',
  bool overdue = false,
}) =>
    KeyHandover(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      propertyAddress: propertyAddress,
      propertyCity: propertyCity,
      holderUserId: holderUserId,
      holderName: holderName,
      note: note,
      handedOutAt: keyMoment(-outDaysAgo),
      dueBackAt: dueBackAt,
      returnedAt: returnedAt,
      handedOutById: handedOutByName == null ? null : 2,
      handedOutByName: handedOutByName,
      returnedById: returnedAt == null ? null : 3,
      returnedByName: returnedAt == null ? null : 'Timur Aliev',
      overdue: overdue,
    );

/// Five handovers that are over, the newest first.
final keysHistory = [
  for (var i = 0; i < 5; i++)
    keyHandover(
      id: 100 + i,
      holderName: i.isEven
          ? 'Saule Nurlanovna-Bekmukhambetova, the owner'
          : 'Timur Aliev',
      holderUserId: i.isEven ? null : 3,
      outDaysAgo: 10 + i * 7,
      returnedAt: keyMoment(-9 - i * 7, hour: 18),
    ),
];

/// A listing whose keys are a day overdue with a cleaner, a long note on
/// them, and a past to show.
PropertyKeys overdueKeys() => PropertyKeys(
      current: keyHandover(
        id: 10,
        holderName: 'Gulnara Serikbaykyzy-Nurmukhambetova, cleaning company',
        note: 'Both keys, the intercom fob and the parking card; '
            'leave them with the concierge if nobody is in the office.',
        outDaysAgo: 4,
        dueBackAt: keyDay(-1),
        overdue: true,
      ),
      history: keysHistory,
    );

/// A listing whose keys are in the office, with two handovers behind them.
PropertyKeys keysInOffice() =>
    PropertyKeys(history: keysHistory.take(2).toList());

/// The keys-out list as the server sends it: overdue first, then by the day
/// due back, the ones without a day last.
final keysOutList = [
  keyHandover(
    id: 21,
    propertyId: 11,
    propertyTitle: 'Esentai Park, apartment 12 with a deliberately long name',
    propertyAddress: 'Al-Farabi 77/7, block 3, entrance 2',
    propertyCity: 'Almaty',
    holderName: 'Gulnara Serikbaykyzy-Nurmukhambetova',
    outDaysAgo: 9,
    dueBackAt: keyDay(-3),
    overdue: true,
  ),
  keyHandover(
    id: 22,
    propertyId: 12,
    propertyTitle: 'Dostyk 5',
    propertyAddress: 'Dostyk 5',
    holderUserId: 3,
    holderName: 'Timur Aliev',
    outDaysAgo: 1,
    dueBackAt: keyDay(0),
  ),
  keyHandover(
    id: 23,
    propertyId: 13,
    propertyTitle: 'Kok-Tobe house',
    propertyAddress: 'Kok-Tobe 1',
    holderName: 'Saule, the owner',
    outDaysAgo: 3,
    dueBackAt: DateTime(2027, 1, 20),
  ),
  keyHandover(
    id: 24,
    propertyId: 14,
    propertyTitle: 'Abaya 10',
    holderName: 'Arman Ospanov',
    outDaysAgo: 20,
  ),
];
