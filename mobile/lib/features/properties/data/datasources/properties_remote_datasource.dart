import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class PropertiesRemoteDataSource {
  final ApiClient _client;
  PropertiesRemoteDataSource(this._client);

  Future<PagedResponse<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    final res = await _client.dio.get('/properties', queryParameters: {
      if (status != null) 'status': status.name,
      if (type != null) 'type': type.name,
      if (city != null && city.isNotEmpty) 'city': city,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'size': size,
    });
    return PagedResponse.parse(res.data, PropertyResponse.fromJson,
        requestedPage: page);
  }

  Future<List<PropertyResponse>> getAllProperties() async {
    final res = await _client.dio.get('/properties');

    return PagedResponse.parse(res.data, PropertyResponse.fromJson).content;
  }

  Future<PropertyResponse> getProperty(int id) async {
    final res = await _client.dio.get('/properties/$id');
    return PropertyResponse.fromJson(jsonObject(res));
  }

  Future<PropertyResponse> createProperty(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/properties', data: data);
    return PropertyResponse.fromJson(jsonObject(res));
  }

  Future<PropertyResponse> updateProperty(
      int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/properties/$id', data: data);
    return PropertyResponse.fromJson(jsonObject(res));
  }

  Future<PropertyResponse> updatePropertyStatus(
      int id, PropertyStatus status) async {
    final res = await _client.dio.patch('/properties/$id/status',
        queryParameters: {'status': status.name});
    return PropertyResponse.fromJson(jsonObject(res));
  }

  Future<void> deleteProperty(int id) async {
    await _client.dio.delete('/properties/$id');
  }

  Future<List<MeetingResponse>> getViewings(int id) async {
    final res = await _client.dio.get('/properties/$id/viewings');
    return jsonArray(res).map(MeetingResponse.fromJson).toList();
  }

  Future<List<ClientMatch>> getInterested(int id) async {
    final res = await _client.dio.get('/properties/$id/interested');
    return jsonArray(res).map(ClientMatch.fromJson).toList();
  }
}
