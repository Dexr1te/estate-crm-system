import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class DealCommentsRemoteDataSource {
  final ApiClient _client;
  DealCommentsRemoteDataSource(this._client);

  Future<DealCommentPage> getComments(int dealId,
      {int? before, int? limit}) async {
    final res =
        await _client.dio.get('/deals/$dealId/comments', queryParameters: {
      if (before != null) 'before': before,
      if (limit != null) 'limit': limit,
    });
    return DealCommentPage.fromJson(jsonObject(res));
  }

  Future<List<AgentOption>> getMentionable(int dealId) async {
    final res = await _client.dio.get('/deals/$dealId/comments/mentionable');
    return jsonArray(res).map(AgentOption.fromJson).toList();
  }

  Future<DealComment> addComment(int dealId,
      {required String body, List<int> mentionedUserIds = const []}) async {
    final res = await _client.dio.post('/deals/$dealId/comments',
        data: {'body': body, 'mentionedUserIds': mentionedUserIds});
    return DealComment.fromJson(jsonObject(res));
  }

  Future<DealComment> updateComment(int dealId, int commentId,
      {required String body, required List<int> mentionedUserIds}) async {
    final res = await _client.dio.put('/deals/$dealId/comments/$commentId',
        data: {'body': body, 'mentionedUserIds': mentionedUserIds});
    return DealComment.fromJson(jsonObject(res));
  }

  Future<void> deleteComment(int dealId, int commentId) async {
    await _client.dio.delete('/deals/$dealId/comments/$commentId');
  }
}
