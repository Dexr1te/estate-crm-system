import 'package:real_estate_crm/core/models/models.dart';

/// A day as the server takes it: "2026-10-12".
String offerDateParam(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String? _clean(String? note) {
  final trimmed = note?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

/// A buyer's offer as first recorded on a listing.
class OfferDraft {
  final int clientId;
  final double amount;
  final DateTime? expiresOn;
  final String? note;

  const OfferDraft({
    required this.clientId,
    required this.amount,
    this.expiresOn,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'amount': amount,
        if (expiresOn != null) 'expiresOn': offerDateParam(expiresOn!),
        if (_clean(note) != null) 'note': _clean(note),
      };
}

/// A new figure on the table, from the buyer or the seller.
class CounterDraft {
  final double amount;
  final OfferParty party;
  final DateTime? expiresOn;
  final String? note;

  const CounterDraft({
    required this.amount,
    required this.party,
    this.expiresOn,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'party': switch (party) {
          OfferParty.buyer => 'BUYER',
          OfferParty.seller => 'SELLER',
        },
        if (expiresOn != null) 'expiresOn': offerDateParam(expiresOn!),
        if (_clean(note) != null) 'note': _clean(note),
      };
}

/// How an offer is decided.
enum OfferDecision { accept, reject, withdraw }

abstract class OffersRepository {
  /// A listing's offers, the highest first.
  Future<List<PropertyOffer>> getForProperty(int propertyId);

  /// A buyer's offers, the latest first.
  Future<List<PropertyOffer>> getForClient(int clientId);

  /// One offer with its negotiation.
  Future<PropertyOffer> getOffer(int id);

  /// Records a buyer's offer on [propertyId].
  Future<PropertyOffer> create(int propertyId, OfferDraft draft);

  /// Puts a new figure on the table.
  Future<PropertyOffer> counter(int id, CounterDraft draft);

  /// Accepts, rejects or withdraws it, with an optional word on why.
  Future<PropertyOffer> decide(int id, OfferDecision decision, {String? note});
}
