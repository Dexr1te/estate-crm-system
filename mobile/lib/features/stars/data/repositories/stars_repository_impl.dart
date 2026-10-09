import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/features/stars/data/datasources/stars_remote_datasource.dart';
import 'package:real_estate_crm/features/stars/domain/repositories/stars_repository.dart';

class StarsRepositoryImpl implements StarsRepository {
  final StarsRemoteDataSource _remote;
  StarsRepositoryImpl(this._remote);

  @override
  Future<List<StarredItem>> getStars() => _remote.getStars();

  @override
  Future<StarredItem> star(StarKey key) => _remote.star(key);

  @override
  Future<void> unstar(StarKey key) => _remote.unstar(key);
}
