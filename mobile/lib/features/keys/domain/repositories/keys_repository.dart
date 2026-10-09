import 'package:real_estate_crm/core/models/key_models.dart';

abstract class KeysRepository {
  /// Who has the listing's keys now, and the handovers that are over, the
  /// newest first (at most 50). Behind the listing's own wall.
  Future<PropertyKeys> getForProperty(int propertyId);

  /// Hands the listing's keys out; answers with its keys as they are now.
  /// Refused with KEY_ALREADY_OUT when they are out already.
  Future<PropertyKeys> handOver(int propertyId, KeyHandoverDraft draft);

  /// Takes the listing's keys back; answers with its keys as they are now.
  /// Refused with KEY_NOT_OUT when they are in the office.
  Future<PropertyKeys> returnKeys(int propertyId);

  /// Every key out of a listing the user can see: overdue first, then by the
  /// day they are due back, the ones without a day last.
  Future<List<KeyHandover>> getKeysOut();
}
