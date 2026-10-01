import 'package:real_estate_crm/core/models/models.dart';

/// When an open house runs and what to remember about it — what the
/// schedule sheet sends.
class OpenHouseDraft {
  final DateTime startsAt;
  final DateTime endsAt;
  final String? note;

  const OpenHouseDraft({
    required this.startsAt,
    required this.endsAt,
    this.note,
  });
}

/// One visitor at the door, as the sign-in sheet takes them.
class VisitorDraft {
  final String fullName;
  final String phone;
  final OpenHouseInterest? interest;
  final String? note;

  const VisitorDraft({
    required this.fullName,
    required this.phone,
    this.interest,
    this.note,
  });
}

abstract class OpenHousesRepository {
  /// A listing's open houses, the latest first, each with its summary; the
  /// whole agency sees them, as it sees the listing.
  Future<List<OpenHouse>> getForProperty(int propertyId);

  /// Open houses overlapping `[from, to)` within the caller's data scope.
  Future<List<OpenHouse>> getBetween(DateTime from, DateTime to);

  /// One open house with its sign-in sheet, latest arrival first.
  Future<OpenHouse> getOpenHouse(int id);

  Future<OpenHouse> create(int propertyId, OpenHouseDraft draft);

  /// The host's, a manager's or an admin's, like [delete].
  Future<OpenHouse> update(int id, OpenHouseDraft draft);

  /// Refused with OPEN_HOUSE_HAS_VISITORS once anybody has signed in.
  Future<void> delete(int id);

  /// Matched to the agency's clients by phone, or a new buyer; refused with
  /// ALREADY_SIGNED_IN for a number already on the sheet.
  Future<OpenHouseVisitor> signIn(int id, VisitorDraft visitor);

  Future<void> removeVisitor(int id, int visitorId);
}
