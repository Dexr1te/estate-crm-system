import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/properties/data/datasources/properties_remote_datasource.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  final PropertiesRemoteDataSource _remote;
  PropertiesRepositoryImpl(this._remote);

  @override
  Future<PagedResponse<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 0,
    int size = 20,
  }) =>
      _remote.getProperties(
        status: status,
        type: type,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        search: search,
        page: page,
        size: size,
      );

  @override
  Future<List<PropertyResponse>> getAllProperties() =>
      _remote.getAllProperties();

  @override
  Future<PropertyResponse> getProperty(int id) => _remote.getProperty(id);

  @override
  Future<PropertyResponse> createProperty(Map<String, dynamic> data) =>
      _remote.createProperty(data);

  @override
  Future<PropertyResponse> updateProperty(int id, Map<String, dynamic> data) =>
      _remote.updateProperty(id, data);

  @override
  Future<PropertyResponse> updatePropertyStatus(int id, PropertyStatus status) =>
      _remote.updatePropertyStatus(id, status);

  @override
  Future<void> deleteProperty(int id) => _remote.deleteProperty(id);
}
