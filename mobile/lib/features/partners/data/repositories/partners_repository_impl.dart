import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/partners/data/datasources/partners_remote_datasource.dart';
import 'package:real_estate_crm/features/partners/domain/repositories/partners_repository.dart';

class PartnersRepositoryImpl implements PartnersRepository {
  final PartnersRemoteDataSource _remote;
  PartnersRepositoryImpl(this._remote);

  @override
  Future<List<Partner>> getPartners({PartnerKind? kind, String? search}) =>
      _remote.getPartners(kind: kind, search: search);

  @override
  Future<Partner> getPartner(int id) => _remote.getPartner(id);

  @override
  Future<Partner> create(PartnerDraft draft) => _remote.create(draft);

  @override
  Future<Partner> update(int id, PartnerDraft draft) =>
      _remote.update(id, draft);

  @override
  Future<void> delete(int id) => _remote.delete(id);

  @override
  Future<List<PartnerReferral>> getReferrals(int id) =>
      _remote.getReferrals(id);

  @override
  Future<List<PartnerHandoff>> getPartnerHandoffs(int id) =>
      _remote.getPartnerHandoffs(id);

  @override
  Future<List<PartnerHandoff>> getClientHandoffs(int clientId) =>
      _remote.getClientHandoffs(clientId);

  @override
  Future<PartnerHandoff> createHandoff(int clientId, HandoffDraft draft) =>
      _remote.createHandoff(clientId, draft);

  @override
  Future<PartnerHandoff> updateHandoff(
          int clientId, int handoffId, HandoffDraft draft) =>
      _remote.updateHandoff(clientId, handoffId, draft);

  @override
  Future<void> deleteHandoff(int clientId, int handoffId) =>
      _remote.deleteHandoff(clientId, handoffId);
}
