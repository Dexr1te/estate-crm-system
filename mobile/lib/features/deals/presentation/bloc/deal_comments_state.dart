import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum DealCommentsStatus { loading, loaded, error }

class DealCommentsState {
  final DealCommentsStatus status;

  /// Oldest first. A comment still on its way carries a negative id.
  final List<DealComment> comments;
  final bool hasEarlier;
  final bool loadingEarlier;
  final bool sending;
  final ApiFailure? loadFailure;

  /// What the last write came to, for a snackbar; each one is a new object.
  final ActionOutcome? outcome;

  /// Text of a comment that failed to send, handed back to the composer.
  final DealCommentDraft? returnedDraft;

  const DealCommentsState({
    this.status = DealCommentsStatus.loading,
    this.comments = const [],
    this.hasEarlier = false,
    this.loadingEarlier = false,
    this.sending = false,
    this.loadFailure,
    this.outcome,
    this.returnedDraft,
  });

  bool isPending(DealComment c) => c.id < 0;

  DealCommentsState copyWith({
    DealCommentsStatus? status,
    List<DealComment>? comments,
    bool? hasEarlier,
    bool? loadingEarlier,
    bool? sending,
    ApiFailure? loadFailure,
    ActionOutcome? outcome,
    DealCommentDraft? returnedDraft,
  }) =>
      DealCommentsState(
        status: status ?? this.status,
        comments: comments ?? this.comments,
        hasEarlier: hasEarlier ?? this.hasEarlier,
        loadingEarlier: loadingEarlier ?? this.loadingEarlier,
        sending: sending ?? this.sending,
        loadFailure: loadFailure,
        outcome: outcome,
        returnedDraft: returnedDraft,
      );
}

class DealCommentDraft {
  final String body;
  final List<CommentMention> mentions;
  const DealCommentDraft(this.body, this.mentions);
}

class DealCommentWritten with ActionSucceeded {
  @override
  final ActionMessage message;
  DealCommentWritten(this.message);
}

/// A write that did not go through. A mention the server refused gets its own
/// sentence; the server's is English.
class DealCommentWriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  DealCommentWriteFailed(this.failure);

  @override
  String text(AppLocalizations l10n) =>
      failure.serverCode == 'MENTION_NOT_ALLOWED'
          ? l10n.dealsCommentMentionNotAllowed
          : apiFailureLabel(l10n, failure);
}
