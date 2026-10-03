import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/offers/data/datasources/offers_remote_datasource.dart';
import 'package:real_estate_crm/features/offers/domain/repositories/offers_repository.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource _remote;
  OffersRepositoryImpl(this._remote);

  @override
  Future<List<PropertyOffer>> getForProperty(int propertyId) =>
      _remote.getForProperty(propertyId);

  @override
  Future<List<PropertyOffer>> getForClient(int clientId) =>
      _remote.getForClient(clientId);

  @override
  Future<PropertyOffer> getOffer(int id) => _remote.getOffer(id);

  @override
  Future<PropertyOffer> create(int propertyId, OfferDraft draft) =>
      _remote.create(propertyId, draft);

  @override
  Future<PropertyOffer> counter(int id, CounterDraft draft) =>
      _remote.counter(id, draft);

  @override
  Future<PropertyOffer> decide(int id, OfferDecision decision,
          {String? note}) =>
      _remote.decide(id, decision, note: note);
}
