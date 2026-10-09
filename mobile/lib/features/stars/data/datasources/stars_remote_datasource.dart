import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class StarsRemoteDataSource {
  final ApiClient _client;
  StarsRemoteDataSource(this._client);

  Future<List<StarredItem>> getStars() async {
    final res = await _client.dio.get('/stars');
    return jsonArray(res)
        .map(StarredItem.tryParse)
        .whereType<StarredItem>()
        .toList();
  }

  Future<StarredItem> star(StarKey key) async {
    final res = await _client.dio.put(_path(key));
    final item = StarredItem.tryParse(jsonObject(res));
    if (item == null) {
      throw ApiFormatException(
        path: res.requestOptions.path,
        expected: 'a starred record',
        received: res.data,
      );
    }
    return item;
  }

  Future<void> unstar(StarKey key) async {
    await _client.dio.delete(_path(key));
  }

  static String _path(StarKey key) => '/stars/${key.type.wire}/${key.id}';
}
