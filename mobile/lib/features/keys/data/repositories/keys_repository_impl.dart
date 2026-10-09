import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/features/keys/data/datasources/keys_remote_datasource.dart';
import 'package:real_estate_crm/features/keys/domain/repositories/keys_repository.dart';

class KeysRepositoryImpl implements KeysRepository {
  final KeysRemoteDataSource _remote;
  KeysRepositoryImpl(this._remote);

  @override
  Future<PropertyKeys> getForProperty(int propertyId) =>
      _remote.getForProperty(propertyId);

  @override
  Future<PropertyKeys> handOver(int propertyId, KeyHandoverDraft draft) =>
      _remote.handOver(propertyId, draft);

  @override
  Future<PropertyKeys> returnKeys(int propertyId) =>
      _remote.returnKeys(propertyId);

  @override
  Future<List<KeyHandover>> getKeysOut() => _remote.getKeysOut();
}
