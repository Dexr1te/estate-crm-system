import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the `/properties` endpoints.
class PropertiesRemoteDataSource {
  final ApiClient _client;
  PropertiesRemoteDataSource(this._client);

  Future<List<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    final res = await _client.dio.get('/properties', queryParameters: {
      if (status != null) 'status': status.name,
      if (type != null) 'type': type.name,
      if (city != null && city.isNotEmpty) 'city': city,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (res.data as List).map((e) => PropertyResponse.fromJson(e)).toList();
  }

  Future<PropertyResponse> getProperty(int id) async {
    final res = await _client.dio.get('/properties/$id');
    return PropertyResponse.fromJson(res.data);
  }

  Future<PropertyResponse> createProperty(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/properties', data: data);
    return PropertyResponse.fromJson(res.data);
  }

  Future<PropertyResponse> updateProperty(
      int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/properties/$id', data: data);
    return PropertyResponse.fromJson(res.data);
  }

  Future<PropertyResponse> updatePropertyStatus(
      int id, PropertyStatus status) async {
    final res = await _client.dio.patch('/properties/$id/status',
        queryParameters: {'status': status.name});
    return PropertyResponse.fromJson(res.data);
  }

  Future<void> deleteProperty(int id) async {
    await _client.dio.delete('/properties/$id');
  }
}
