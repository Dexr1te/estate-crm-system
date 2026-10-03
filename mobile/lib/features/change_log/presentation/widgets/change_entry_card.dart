import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/change_log/domain/change_entry.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_labels.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One save on the timeline: who, when, and each field that moved. In the
/// agency's feed it also names the record, which opens on a tap unless the
/// entry is its deletion.
class ChangeEntryCard extends StatelessWidget {
  final ChangeEntry entry;
  final bool showRecord;
  final VoidCallback? onOpenRecord;

  const ChangeEntryCard({
    super.key,
    required this.entry,
    this.showRecord = false,
    this.onOpenRecord,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final at = entry.changedAt;
    final record = entry.entityLabel?.trim();

    final open = onOpenRecord;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.surfaceVariant,
              borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
            ),
            child: Icon(_icon(entry), size: 16, color: t.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  changeActorLabel(l10n, entry),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                if (at != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    activityTimeLabel(l10n, at, AppClock.now(), locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        color: t.textHint),
                  ),
                ],
                if (showRecord) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    key: ValueKey(
                        'change-record-${entry.entityType?.name}-${entry.entityId}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: entry.isDeletion ? null : open,
                    child: Text(
                      l10n.changeLogRecord(
                        changeEntityTypeLabel(l10n, entry.entityType),
                        record == null || record.isEmpty
                            ? l10n.changeLogUntitled
                            : record,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: entry.isDeletion || open == null
                              ? t.textSecondary
                              : t.primary),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                for (final line in entry.lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      changeLineLabel(l10n, line, locale),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 13,
                          height: 1.35,
                          color: t.textPrimary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _icon(ChangeEntry entry) {
    if (entry.lines.any((l) => l.action == ChangeAction.created)) {
      return Icons.add_circle_outline_rounded;
    }
    if (entry.isDeletion) return Icons.delete_outline_rounded;
    if (entry.lines.any((l) => l.action == ChangeAction.agentChanged)) {
      return Icons.swap_horiz_rounded;
    }
    return Icons.edit_outlined;
  }
}

/// A timeline entry still loading: a card the shape of one with two lines.
class ChangeEntryBone extends StatelessWidget {
  const ChangeEntryBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 30, height: 30, radius: 10),
          trailing: SizedBox.shrink(),
          titleFactor: 0.5,
          subtitleFactor: 0.8,
        ),
      );
}
