import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/deals/data/datasources/deal_comments_remote_datasource.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deal_comments_repository.dart';

class DealCommentsRepositoryImpl implements DealCommentsRepository {
  final DealCommentsRemoteDataSource _remote;
  DealCommentsRepositoryImpl(this._remote);

  @override
  Future<DealCommentPage> getComments(int dealId, {int? before, int? limit}) =>
      _remote.getComments(dealId, before: before, limit: limit);

  @override
  Future<List<AgentOption>> getMentionable(int dealId) =>
      _remote.getMentionable(dealId);

  @override
  Future<DealComment> addComment(int dealId,
          {required String body, List<int> mentionedUserIds = const []}) =>
      _remote.addComment(dealId,
          body: body, mentionedUserIds: mentionedUserIds);

  @override
  Future<DealComment> updateComment(int dealId, int commentId,
          {required String body, required List<int> mentionedUserIds}) =>
      _remote.updateComment(dealId, commentId,
          body: body, mentionedUserIds: mentionedUserIds);

  @override
  Future<void> deleteComment(int dealId, int commentId) =>
      _remote.deleteComment(dealId, commentId);
}
