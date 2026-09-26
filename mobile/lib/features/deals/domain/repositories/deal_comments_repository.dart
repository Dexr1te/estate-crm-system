import 'package:real_estate_crm/core/models/models.dart';

abstract class DealCommentsRepository {
  /// The latest comments on a deal, oldest first; older than [before] when
  /// given, for "show earlier".
  Future<DealCommentPage> getComments(int dealId, {int? before, int? limit});

  /// Colleagues who can open the deal and so can be @mentioned in it.
  Future<List<AgentOption>> getMentionable(int dealId);

  Future<DealComment> addComment(int dealId,
      {required String body, List<int> mentionedUserIds = const []});

  Future<DealComment> updateComment(int dealId, int commentId,
      {required String body, required List<int> mentionedUserIds});

  Future<void> deleteComment(int dealId, int commentId);
}
