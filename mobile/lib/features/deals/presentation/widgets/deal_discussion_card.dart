import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deal_comments_repository.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deal_comments_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deal_comments_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deal_comments_state.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_comment_composer.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_comment_row.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_comment_sheets.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_mention_picker.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The conversation about a deal, oldest at the top, with a place to add to it
/// at the bottom.
///
/// A screen that reloads the discussion itself — on pull to refresh — makes
/// the bloc with [createBloc] and hands it in as [bloc]; otherwise the card
/// makes and owns its own.
class DealDiscussionCard extends StatelessWidget {
  final int dealId;
  final DealCommentsBloc? bloc;
  const DealDiscussionCard({super.key, required this.dealId, this.bloc});

  /// The discussion of [dealId], as whoever is signed in, already loading.
  static DealCommentsBloc createBloc(BuildContext context, int dealId) {
    final me = context.read<AuthBloc>().currentUser;
    return DealCommentsBloc(
      Injector.dealCommentsRepository,
      dealId: dealId,
      authorId: me?.userId,
      authorName: me?.fullName ?? '',
    )..add(DealCommentsLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final body = _DiscussionBody(
        dealId: dealId, repository: Injector.dealCommentsRepository);
    final given = bloc;
    if (given != null) return BlocProvider.value(value: given, child: body);
    return BlocProvider(
        create: (context) => createBloc(context, dealId), child: body);
  }
}

class _DiscussionBody extends StatefulWidget {
  final int dealId;
  final DealCommentsRepository repository;
  const _DiscussionBody({required this.dealId, required this.repository});

  @override
  State<_DiscussionBody> createState() => _DiscussionBodyState();
}

class _DiscussionBodyState extends State<_DiscussionBody> {
  final _draft = DealCommentDraftSlot();

  void _onChange(BuildContext context, DealCommentsState state) {
    showActionOutcome(context, state.outcome);
    final returned = state.returnedDraft;
    if (returned != null) _draft.restore(returned.body, returned.mentions);
  }

  Future<CommentMention?> _pickMention(BuildContext context) =>
      showMentionPicker(context,
          repository: widget.repository,
          dealId: widget.dealId,
          excludeUserId: context.currentUserId);

  void _openActions(BuildContext context, DealComment comment) {
    final mine =
        comment.authorId != null && comment.authorId == context.currentUserId;
    final bloc = context.read<DealCommentsBloc>();
    showCommentActions(
      context,
      canEdit: mine,
      canDelete: mine || context.isAdminOrManager,
      onEdit: () => showEditCommentSheet(context, comment,
          onSave: (body) => bloc.add(DealCommentsEditEvent(comment, body,
              mentions: comment.mentions))),
      onDelete: () => bloc.add(DealCommentsDeleteEvent(comment)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<DealCommentsBloc, DealCommentsState>(
      listenWhen: (a, b) =>
          b.outcome != a.outcome || b.returnedDraft != a.returnedDraft,
      listener: _onChange,
      builder: (context, state) {
        final comments = state.comments;
        final mine = context.currentUserId;
        final manages = context.isAdminOrManager;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(child: EyebrowLabel(l10n.dealsDiscussion)),
                if (comments.isNotEmpty)
                  Text('${comments.length}',
                      maxLines: 1,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: t.textSecondary)),
              ]),
              const SizedBox(height: 8),
              if (state.status == DealCommentsStatus.loading)
                const _DiscussionSkeleton()
              else if (state.status == DealCommentsStatus.error)
                _DiscussionProblem(
                    onRetry: () => context
                        .read<DealCommentsBloc>()
                        .add(DealCommentsLoadEvent()))
              else if (comments.isEmpty)
                const _DiscussionEmpty()
              else ...[
                if (state.hasEarlier)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppGhostButton(
                      label: l10n.dealsDiscussionShowEarlier,
                      loading: state.loadingEarlier,
                      height: AppMetrics.buttonHeightInline,
                      fontSize: 12,
                      onPressed: () => context
                          .read<DealCommentsBloc>()
                          .add(DealCommentsLoadEarlierEvent()),
                    ),
                  ),
                for (final c in comments)
                  DealCommentRow(
                    key: ValueKey('comment-row-${c.id}'),
                    comment: c,
                    pending: state.isPending(c),
                    onLongPress: state.isPending(c) ||
                            !((c.authorId != null && c.authorId == mine) ||
                                manages)
                        ? null
                        : () => _openActions(context, c),
                  ),
              ],
              const SizedBox(height: 10),
              DealCommentComposer(
                draftSlot: _draft,
                sending: state.sending,
                pickMention: _pickMention,
                onSend: (body, mentions) => context
                    .read<DealCommentsBloc>()
                    .add(DealCommentsSendEvent(body, mentions: mentions)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DiscussionSkeleton extends StatelessWidget {
  const _DiscussionSkeleton();

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: Column(children: [
          _SkeletonRow(widthFactor: 0.8),
          SizedBox(height: 14),
          _SkeletonRow(widthFactor: 0.55),
        ]),
      );
}

class _SkeletonRow extends StatelessWidget {
  final double widthFactor;
  const _SkeletonRow({required this.widthFactor});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerCircle(size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(children: [
              const ShimmerBar(widthFactor: 0.35, height: 11),
              const SizedBox(height: 7),
              ShimmerBar(widthFactor: widthFactor, height: 12),
            ]),
          ),
        ],
      );
}

class _DiscussionEmpty extends StatelessWidget {
  const _DiscussionEmpty();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dealsDiscussionEmpty,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: t.textPrimary)),
          const SizedBox(height: 4),
          Text(l10n.dealsDiscussionEmptyHint,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12,
                  height: 1.45,
                  color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _DiscussionProblem extends StatelessWidget {
  final VoidCallback onRetry;
  const _DiscussionProblem({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Row(children: [
      Expanded(
        child: Text(l10n.dealsDiscussionLoadFailed,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary)),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: AppGhostButton(
          label: l10n.coreRetry,
          onPressed: onRetry,
          height: AppMetrics.buttonHeightInline,
          fontSize: 12,
        ),
      ),
    ]);
  }
}
