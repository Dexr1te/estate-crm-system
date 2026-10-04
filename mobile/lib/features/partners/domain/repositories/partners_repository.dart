import 'package:real_estate_crm/core/models/models.dart';

/// A partner as the form sends it. The fee is both halves or neither.
class PartnerDraft {
  final String name;
  final String? company;
  final PartnerKind kind;
  final String? phone;
  final String? email;
  final String? note;
  final ReferralFeeType? feeType;
  final double? feeValue;

  const PartnerDraft({
    required this.name,
    required this.kind,
    this.company,
    this.phone,
    this.email,
    this.note,
    this.feeType,
    this.feeValue,
  });
}

/// A client sent to a partner, as the hand-off sheet sends it.
class HandoffDraft {
  final int partnerId;
  final DateTime sentOn;
  final PartnerHandoffStatus status;
  final String? note;

  const HandoffDraft({
    required this.partnerId,
    required this.sentOn,
    required this.status,
    this.note,
  });
}

abstract class PartnersRepository {
  /// The agency's partners by name, narrowed by [kind] and by a word in the
  /// name, company or phone.
  Future<List<Partner>> getPartners({PartnerKind? kind, String? search});

  Future<Partner> getPartner(int id);

  Future<Partner> create(PartnerDraft draft);

  /// Whoever added it, a manager or an admin, like [delete].
  Future<Partner> update(int id, PartnerDraft draft);

  /// Refused with PARTNER_IN_USE while any client is linked to it.
  Future<void> delete(int id);

  /// The clients the partner sent that the signed-in user sees.
  Future<List<PartnerReferral>> getReferrals(int id);

  /// The clients sent to the partner that the signed-in user sees.
  Future<List<PartnerHandoff>> getPartnerHandoffs(int id);

  /// The partners a client was sent to, the latest first.
  Future<List<PartnerHandoff>> getClientHandoffs(int clientId);

  Future<PartnerHandoff> createHandoff(int clientId, HandoffDraft draft);

  Future<PartnerHandoff> updateHandoff(
      int clientId, int handoffId, HandoffDraft draft);

  Future<void> deleteHandoff(int clientId, int handoffId);
}
