import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deal_comments_repository.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The colleagues who can open this deal — the only people the server lets a
/// comment mention — minus the one writing.
Future<CommentMention?> showMentionPicker(
  BuildContext context, {
  required DealCommentsRepository repository,
  required int dealId,
  int? excludeUserId,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<CommentMention>(
    context,
    title: l10n.dealsCommentMentionTitle,
    builder: (_) => _MentionList(
      load: () => repository.getMentionable(dealId),
      excludeUserId: excludeUserId,
    ),
  );
}

class _MentionList extends StatefulWidget {
  final Future<List<AgentOption>> Function() load;
  final int? excludeUserId;
  const _MentionList({required this.load, this.excludeUserId});

  @override
  State<_MentionList> createState() => _MentionListState();
}

class _MentionListState extends State<_MentionList> {
  late Future<List<AgentOption>> _people = widget.load();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    TextStyle line(Color color) =>
        TextStyle(fontFamily: AppFonts.sans, fontSize: 13, color: color);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FutureBuilder<List<AgentOption>>(
        future: _people,
        builder: (context, snap) {
          if (snap.hasError) {
            return Row(children: [
              Expanded(
                child: Text(l10n.dealsCommentMentionLoadFailed,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: line(t.textSecondary)),
              ),
              Flexible(
                child: AppGhostButton(
                  label: l10n.coreRetry,
                  height: AppMetrics.buttonHeightInline,
                  fontSize: 12,
                  onPressed: () => setState(() => _people = widget.load()),
                ),
              ),
            ]);
          }
          final people = snap.data;
          if (people == null) {
            return const ShimmerGroup(
              child: Column(children: [
                ShimmerBar(widthFactor: 0.6, height: 14),
                SizedBox(height: 18),
                ShimmerBar(widthFactor: 0.45, height: 14),
                SizedBox(height: 18),
                ShimmerBar(widthFactor: 0.55, height: 14),
              ]),
            );
          }
          final others =
              people.where((p) => p.id != widget.excludeUserId).toList();
          if (others.isEmpty) {
            return Text(l10n.dealsCommentMentionNone,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: line(t.textSecondary));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final p in others)
                InkWell(
                  key: ValueKey('mention-option-${p.id}'),
                  borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
                  onTap: () => Navigator.of(context)
                      .pop(CommentMention(id: p.id, fullName: p.fullName)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: AppMetrics.minHitTarget + 4),
                    child: Row(children: [
                      InitialAvatar(name: p.fullName, size: 30),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(p.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: line(t.textPrimary)
                                .copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
