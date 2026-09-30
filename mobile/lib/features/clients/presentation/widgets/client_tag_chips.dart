import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One of the agency's tags, as a label. Outlined and neutral: a tag is the
/// agent's own word, not a status, so it takes no colour.
class ClientTagChip extends StatelessWidget {
  final String tag;

  /// Shown after the name; the editor puts a remove mark here.
  final Widget? trailing;

  const ClientTagChip({super.key, required this.tag, this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.fromLTRB(9, 4, trailing == null ? 9 : 5, 4),
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        borderRadius: BorderRadius.circular(AppMetrics.radiusPill),
        border: Border.all(color: t.border, width: AppMetrics.borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              tag,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: t.textSecondary),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 3), trailing!],
        ],
      ),
    );
  }
}

/// A client's tags. With [maxVisible], the rest are counted in a last "+N"
/// chip, which keeps a list row to its height however many a client carries.
class ClientTagChips extends StatelessWidget {
  final List<String> tags;
  final int? maxVisible;

  const ClientTagChips({super.key, required this.tags, this.maxVisible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limit = maxVisible;
    final shown =
        limit == null || tags.length <= limit ? tags : tags.take(limit);
    final hidden = tags.length - shown.length;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final tag in shown)
          ClientTagChip(key: ValueKey('client-tag-$tag'), tag: tag),
        if (hidden > 0)
          ClientTagChip(
              key: const ValueKey('client-tags-more'),
              tag: l10n.clientsTagsMore(hidden)),
      ],
    );
  }
}
