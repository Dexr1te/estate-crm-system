import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/open_houses/data/datasources/open_houses_remote_datasource.dart';
import 'package:real_estate_crm/features/open_houses/domain/repositories/open_houses_repository.dart';

class OpenHousesRepositoryImpl implements OpenHousesRepository {
  final OpenHousesRemoteDataSource _remote;
  OpenHousesRepositoryImpl(this._remote);

  @override
  Future<List<OpenHouse>> getForProperty(int propertyId) =>
      _remote.getForProperty(propertyId);

  @override
  Future<List<OpenHouse>> getBetween(DateTime from, DateTime to) =>
      _remote.getBetween(from, to);

  @override
  Future<OpenHouse> getOpenHouse(int id) => _remote.getOpenHouse(id);

  @override
  Future<OpenHouse> create(int propertyId, OpenHouseDraft draft) =>
      _remote.create(propertyId, draft);

  @override
  Future<OpenHouse> update(int id, OpenHouseDraft draft) =>
      _remote.update(id, draft);

  @override
  Future<void> delete(int id) => _remote.delete(id);

  @override
  Future<OpenHouseVisitor> signIn(int id, VisitorDraft visitor) =>
      _remote.signIn(id, visitor);

  @override
  Future<void> removeVisitor(int id, int visitorId) =>
      _remote.removeVisitor(id, visitorId);
}
