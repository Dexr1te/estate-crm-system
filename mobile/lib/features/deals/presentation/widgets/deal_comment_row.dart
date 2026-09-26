import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DealCommentRow extends StatelessWidget {
  final DealComment comment;
  final bool pending;
  final VoidCallback? onLongPress;

  const DealCommentRow({
    super.key,
    required this.comment,
    this.pending = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final name = comment.authorName?.trim() ?? '';
    final shownName = name.isEmpty ? l10n.clientsActivityFormerMember : name;
    final now = AppClock.now();
    final when = pending
        ? l10n.dealsCommentSending
        : now.difference(comment.createdAt).inMinutes < 1
            ? l10n.dealsCommentJustNow
            : activityTimeLabel(l10n, comment.createdAt, now, locale);

    return Opacity(
      opacity: pending ? 0.6 : 1,
      child: GestureDetector(
        key: ValueKey('deal-comment-${comment.id}'),
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialAvatar(name: name, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            shownName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: t.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            [
                              when,
                              if (comment.editedAt != null && !pending)
                                l10n.dealsCommentEdited,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: 11,
                                color: t.textHint),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    CommentBody(comment: comment),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The text of a comment with each @mention picked out, folded after a
/// dozen lines with a way to read the rest.
class CommentBody extends StatefulWidget {
  static const foldedLines = 12;

  final DealComment comment;
  const CommentBody({super.key, required this.comment});

  @override
  State<CommentBody> createState() => _CommentBodyState();
}

class _CommentBodyState extends State<CommentBody> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13,
        height: 1.45,
        color: t.textPrimary);
    final span = TextSpan(
      style: style,
      children: mentionSpans(widget.comment.body, widget.comment.mentions,
          TextStyle(fontWeight: FontWeight.w600, color: t.primary)),
    );

    return LayoutBuilder(builder: (context, constraints) {
      final painter = TextPainter(
        text: span,
        maxLines: CommentBody.foldedLines,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: constraints.maxWidth);
      final folds = painter.didExceedMaxLines;
      painter.dispose();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            span,
            maxLines: _expanded ? null : CommentBody.foldedLines,
            overflow: _expanded ? TextOverflow.clip : TextOverflow.ellipsis,
          ),
          if (folds || _expanded)
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? l10n.dealsCommentLess : l10n.dealsCommentMore,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.textSecondary),
              ),
            ),
        ],
      );
    });
  }
}

/// Splits [body] so every "@Name" of a mentioned person is its own span.
List<TextSpan> mentionSpans(
    String body, List<CommentMention> mentions, TextStyle highlight) {
  final names = {
    for (final m in mentions)
      if (m.fullName.trim().isNotEmpty) '@${m.fullName.trim()}'
  }.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  if (names.isEmpty) return [TextSpan(text: body)];
  final pattern = RegExp(names.map(RegExp.escape).join('|'));
  final spans = <TextSpan>[];
  var from = 0;
  for (final match in pattern.allMatches(body)) {
    if (match.start > from) {
      spans.add(TextSpan(text: body.substring(from, match.start)));
    }
    spans.add(TextSpan(text: match.group(0), style: highlight));
    from = match.end;
  }
  if (from < body.length) spans.add(TextSpan(text: body.substring(from)));
  return spans;
}
