import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deal_comments_repository.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deal_comments_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deal_comments_state.dart';

class DealCommentsBloc extends Bloc<DealCommentsEvent, DealCommentsState> {
  static const pageSize = 30;

  final DealCommentsRepository _repo;
  final int dealId;
  final int? authorId;
  final String authorName;
  int _nextTempId = -1;

  DealCommentsBloc(
    this._repo, {
    required this.dealId,
    this.authorId,
    this.authorName = '',
  }) : super(const DealCommentsState()) {
    on<DealCommentsLoadEvent>(_onLoad);
    on<DealCommentsLoadEarlierEvent>(_onLoadEarlier);
    on<DealCommentsSendEvent>(_onSend);
    on<DealCommentsEditEvent>(_onEdit);
    on<DealCommentsDeleteEvent>(_onDelete);
  }

  Future<void> _onLoad(
      DealCommentsLoadEvent e, Emitter<DealCommentsState> emit) async {
    if (state.status != DealCommentsStatus.loaded) {
      emit(state.copyWith(status: DealCommentsStatus.loading));
    }
    try {
      final page = await _repo.getComments(dealId, limit: pageSize);
      final pending = state.comments.where(state.isPending);
      emit(state.copyWith(
        status: DealCommentsStatus.loaded,
        comments: [...page.comments, ...pending],
        hasEarlier: page.hasEarlier,
      ));
    } catch (error) {
      final failure = ApiFailure.from(error);
      if (state.status == DealCommentsStatus.loaded) {
        emit(state.copyWith(outcome: DealCommentWriteFailed(failure)));
      } else {
        emit(state.copyWith(
            status: DealCommentsStatus.error, loadFailure: failure));
      }
    }
  }

  Future<void> _onLoadEarlier(
      DealCommentsLoadEarlierEvent e, Emitter<DealCommentsState> emit) async {
    final oldest = state.comments.where((c) => c.id > 0).firstOrNull;
    if (state.loadingEarlier || !state.hasEarlier || oldest == null) return;
    emit(state.copyWith(loadingEarlier: true));
    try {
      final page =
          await _repo.getComments(dealId, before: oldest.id, limit: pageSize);
      emit(state.copyWith(
        comments: [...page.comments, ...state.comments],
        hasEarlier: page.hasEarlier,
        loadingEarlier: false,
      ));
    } catch (error) {
      emit(state.copyWith(
          loadingEarlier: false,
          outcome: DealCommentWriteFailed(ApiFailure.from(error))));
    }
  }

  Future<void> _onSend(
      DealCommentsSendEvent e, Emitter<DealCommentsState> emit) async {
    final body = e.body.trim();
    if (body.isEmpty || state.sending) return;
    final mentions = _mentionsIn(body, e.mentions);
    final temp = DealComment(
      id: _nextTempId--,
      dealId: dealId,
      body: body,
      authorId: authorId,
      authorName: authorName,
      createdAt: AppClock.now(),
      mentions: mentions,
    );
    emit(state.copyWith(sending: true, comments: [...state.comments, temp]));
    try {
      final saved = await _repo.addComment(dealId,
          body: body, mentionedUserIds: [for (final m in mentions) m.id]);
      emit(state.copyWith(
        sending: false,
        comments: [for (final c in state.comments) c.id == temp.id ? saved : c],
      ));
    } catch (error) {
      emit(state.copyWith(
        sending: false,
        comments: state.comments.where((c) => c.id != temp.id).toList(),
        outcome: DealCommentWriteFailed(ApiFailure.from(error)),
        returnedDraft: DealCommentDraft(e.body, e.mentions),
      ));
    }
  }

  Future<void> _onEdit(
      DealCommentsEditEvent e, Emitter<DealCommentsState> emit) async {
    final body = e.body.trim();
    if (body.isEmpty || e.comment.id < 0) return;
    final mentions = _mentionsIn(body, e.mentions);
    final before = state.comments
        .firstWhere((c) => c.id == e.comment.id, orElse: () => e.comment);
    _replace(
        emit,
        before.copyWith(
            body: body, mentions: mentions, editedAt: AppClock.now()));
    try {
      final saved = await _repo.updateComment(dealId, before.id,
          body: body, mentionedUserIds: [for (final m in mentions) m.id]);
      _replace(emit, saved,
          outcome: DealCommentWritten(ActionMessage.commentUpdated));
    } catch (error) {
      _replace(emit, before,
          outcome: DealCommentWriteFailed(ApiFailure.from(error)));
    }
  }

  Future<void> _onDelete(
      DealCommentsDeleteEvent e, Emitter<DealCommentsState> emit) async {
    final index = state.comments.indexWhere((c) => c.id == e.comment.id);
    if (index < 0 || e.comment.id < 0) return;
    final removed = state.comments[index];
    emit(state.copyWith(comments: [...state.comments]..removeAt(index)));
    try {
      await _repo.deleteComment(dealId, removed.id);
      emit(state.copyWith(
          outcome: DealCommentWritten(ActionMessage.commentDeleted)));
    } catch (error) {
      final restored = [...state.comments]
        ..insert(index.clamp(0, state.comments.length), removed);
      emit(state.copyWith(
          comments: restored,
          outcome: DealCommentWriteFailed(ApiFailure.from(error))));
    }
  }

  void _replace(Emitter<DealCommentsState> emit, DealComment comment,
      {ActionOutcome? outcome}) {
    emit(state.copyWith(
      comments: [
        for (final c in state.comments) c.id == comment.id ? comment : c
      ],
      outcome: outcome,
    ));
  }

  /// Only the people whose @Name is still in the text: a mention picked and
  /// then deleted from the draft is not sent.
  static List<CommentMention> _mentionsIn(
      String body, List<CommentMention> picked) {
    final seen = <int>{};
    return [
      for (final m in picked)
        if (m.fullName.isNotEmpty &&
            body.contains('@${m.fullName}') &&
            seen.add(m.id))
          m
    ];
  }
}
