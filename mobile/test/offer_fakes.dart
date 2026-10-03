import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/offers/domain/repositories/offers_repository.dart';

/// Offers in memory, keeping the server's rules that the screens react to:
/// one open offer per buyer and listing, one accepted offer per listing, and
/// only open offers taking counters or decisions. Each refusal comes back
/// with the server's code.
class FakeOffersRepository implements OffersRepository {
  final List<PropertyOffer> offers;
  final List<(int, OfferDraft)> created = [];
  final List<(int, CounterDraft)> countered = [];
  final List<(int, OfferDecision)> decided = [];
  int _nextId = 2000;

  /// When set, every read and write fails with it.
  Object? failWith;

  FakeOffersRepository({List<PropertyOffer>? offers}) : offers = offers ?? [];

  void _check() {
    final error = failWith;
    if (error != null) throw error;
  }

  static DioException refusal(String code, {int status = 409}) {
    final options = RequestOptions(path: '/offers');
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: status,
        data: {'code': code, 'message': code},
      ),
      type: DioExceptionType.badResponse,
    );
  }

  PropertyOffer _find(int id) => offers.firstWhere((o) => o.id == id);

  /// What the server works out on every read: whether another offer on the
  /// same listing stands accepted while this one is open.
  PropertyOffer _flagged(PropertyOffer o) {
    final accepted = offers.any((x) =>
        x.propertyId == o.propertyId &&
        x.id != o.id &&
        x.status == OfferStatus.accepted);
    return o.copyWith(otherAccepted: o.status.isOpen && accepted);
  }

  void _put(PropertyOffer o) {
    final i = offers.indexWhere((e) => e.id == o.id);
    if (i < 0) {
      offers.add(o);
    } else {
      offers[i] = o;
    }
  }

  OfferStep _step(PropertyOffer o, OfferAction action, OfferParty? party,
          String? note) =>
      OfferStep(
        id: _nextId++,
        action: action,
        amount: o.amount,
        party: party,
        note: note,
        actorName: 'Aigul Bekova',
        createdAt: DateTime(2026, 10, 4, 12),
      );

  @override
  Future<List<PropertyOffer>> getForProperty(int propertyId) async {
    _check();
    return offers
        .where((o) => o.propertyId == propertyId)
        .map((o) => _flagged(o).copyWith(history: const []))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  @override
  Future<List<PropertyOffer>> getForClient(int clientId) async {
    _check();
    return offers
        .where((o) => o.clientId == clientId)
        .map((o) => _flagged(o).copyWith(history: const []))
        .toList();
  }

  @override
  Future<PropertyOffer> getOffer(int id) async {
    _check();
    return _flagged(_find(id));
  }

  @override
  Future<PropertyOffer> create(int propertyId, OfferDraft draft) async {
    _check();
    if (offers.any((o) =>
        o.propertyId == propertyId &&
        o.clientId == draft.clientId &&
        o.status.isOpen)) {
      throw refusal('OFFER_ALREADY_OPEN');
    }
    created.add((propertyId, draft));
    var o = PropertyOffer(
      id: _nextId++,
      propertyId: propertyId,
      propertyTitle: 'Listing $propertyId',
      clientId: draft.clientId,
      clientVisible: true,
      clientName: 'Buyer ${draft.clientId}',
      amount: draft.amount,
      expiresOn: draft.expiresOn,
      note: draft.note,
      canEdit: true,
    );
    o = o.copyWith(
        history: [_step(o, OfferAction.offered, OfferParty.buyer, draft.note)]);
    _put(o);
    return _flagged(o);
  }

  @override
  Future<PropertyOffer> counter(int id, CounterDraft draft) async {
    _check();
    final o = _find(id);
    if (!o.status.isOpen) throw refusal('OFFER_CLOSED');
    countered.add((id, draft));
    var next = o.copyWith(
      amount: draft.amount,
      lastParty: draft.party,
      status: OfferStatus.countered,
      expiresOn: draft.expiresOn ?? o.expiresOn,
    );
    next = next.copyWith(history: [
      ...o.history,
      _step(next, OfferAction.countered, draft.party, draft.note),
    ]);
    _put(next);
    return _flagged(next);
  }

  @override
  Future<PropertyOffer> decide(int id, OfferDecision decision,
      {String? note}) async {
    _check();
    final o = _find(id);
    final withdrawable = o.status.isOpen || o.status == OfferStatus.accepted;
    if (decision == OfferDecision.withdraw ? !withdrawable : !o.status.isOpen) {
      throw refusal('OFFER_CLOSED');
    }
    if (decision == OfferDecision.accept &&
        offers.any((x) =>
            x.propertyId == o.propertyId && x.status == OfferStatus.accepted)) {
      throw refusal('OFFER_ALREADY_ACCEPTED');
    }
    decided.add((id, decision));
    final (status, action) = switch (decision) {
      OfferDecision.accept => (OfferStatus.accepted, OfferAction.accepted),
      OfferDecision.reject => (OfferStatus.rejected, OfferAction.rejected),
      OfferDecision.withdraw => (OfferStatus.withdrawn, OfferAction.withdrawn),
    };
    final next = o.copyWith(
      status: status,
      decidedAt: DateTime(2026, 10, 4, 12),
      history: [...o.history, _step(o, action, null, note)],
    );
    _put(next);
    return _flagged(next);
  }
}
