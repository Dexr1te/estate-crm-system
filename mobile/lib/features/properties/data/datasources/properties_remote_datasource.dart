import 'package:dio/dio.dart';
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

  Future<List<PropertyPhoto>> getPhotos(int id) async {
    final res = await _client.dio.get('/properties/$id/photos');
    return jsonArray(res).map(PropertyPhoto.fromJson).toList();
  }

  Future<PropertyPhoto> addPhoto(int id, String path, String name) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: name),
    });
    final res = await _client.dio.post('/properties/$id/photos', data: form);
    return PropertyPhoto.fromJson(jsonObject(res));
  }

  Future<List<int>> getPhotoBytes(int id, int photoId) async {
    final res = await _client.dio.get<List<int>>(
      '/properties/$id/photos/$photoId/content',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? const [];
  }

  Future<List<PropertyPhoto>> reorderPhotos(int id, List<int> photoIds) async {
    final res = await _client.dio
        .put('/properties/$id/photos/order', data: {'photoIds': photoIds});
    return jsonArray(res).map(PropertyPhoto.fromJson).toList();
  }

  Future<List<int>> getCoverBytes(int id) async {
    final res = await _client.dio.get<List<int>>(
      '/properties/$id/cover',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? const [];
  }

  Future<void> deletePhoto(int id, int photoId) async {
    await _client.dio.delete('/properties/$id/photos/$photoId');
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
