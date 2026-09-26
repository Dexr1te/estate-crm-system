import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ClientHistoryCard extends StatelessWidget {
  final List<ClientActivity>? activities;
  final VoidCallback onLog;
  final VoidCallback onRetry;
  final ValueChanged<ClientActivity> onDelete;
  final bool Function(ClientActivity) canDelete;

  /// Opens an entry for correcting; offered on the same entries as removal.
  final ValueChanged<ClientActivity>? onEdit;

  /// Opens a listing named in an entry — one that was sent.
  final ValueChanged<int>? onOpenProperty;

  const ClientHistoryCard({
    super.key,
    required this.activities,
    required this.onLog,
    required this.onRetry,
    required this.onDelete,
    required this.canDelete,
    this.onEdit,
    this.onOpenProperty,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final items = activities;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.clientsHistory)),
              if (items != null && items.isNotEmpty)
                Text('${items.length}',
                    maxLines: 1,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          if (items == null)
            _HistoryProblem(onRetry: onRetry)
          else if (items.isEmpty)
            _HistoryEmpty(onLog: onLog)
          else ...[
            for (var i = 0; i < items.length; i++)
              _ActivityRow(
                activity: items[i],
                last: i == items.length - 1,
                onDelete: canDelete(items[i]) ? () => onDelete(items[i]) : null,
                onEdit: onEdit != null && canDelete(items[i])
                    ? () => onEdit!(items[i])
                    : null,
                onOpenProperty: onOpenProperty,
              ),
            const SizedBox(height: 4),
            AppGhostButton(
              label: l10n.clientsLogContact,
              onPressed: onLog,
              height: AppMetrics.minHitTarget,
              fontSize: 12.5,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ClientActivity activity;
  final bool last;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final ValueChanged<int>? onOpenProperty;

  const _ActivityRow({
    required this.activity,
    required this.last,
    required this.onDelete,
    required this.onEdit,
    required this.onOpenProperty,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final note = activity.note?.trim();
    final author = activity.authorName?.trim();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEdit,
      onLongPress: onDelete,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: t.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(activityTypeIcon(activity.type),
                        size: 15, color: t.textSecondary),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: t.border,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 1, bottom: last ? 10 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityTypeLabel(l10n, activity.type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        activityTimeLabel(
                            l10n, activity.occurredAt, AppClock.now(), locale),
                        author == null || author.isEmpty
                            ? l10n.clientsActivityFormerMember
                            : author,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          color: t.textHint),
                    ),
                    if (note != null && note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 12.5,
                            height: 1.45,
                            color: t.textSecondary),
                      ),
                    ],
                    if (activity.properties.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _SentListings(
                        properties: activity.properties,
                        onOpen: onOpenProperty,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (onDelete != null)
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: AppMetrics.minHitTarget,
                  height: AppMetrics.minHitTarget,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: l10n.clientsActivityRemove,
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline_rounded,
                        size: 17, color: t.textHint),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// What went out in a message: how many, and each one by name, a tap away.
class _SentListings extends StatelessWidget {
  final List<ActivityProperty> properties;
  final ValueChanged<int>? onOpen;

  const _SentListings({required this.properties, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.clientsActivitySentListings(properties.length),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: t.textSecondary),
        ),
        for (final p in properties)
          InkWell(
            key: ValueKey('sent-listing-${p.id}'),
            borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
            onTap: onOpen == null ? null : () => onOpen!(p.id),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 32),
              child: Row(
                children: [
                  Icon(Icons.home_work_outlined, size: 14, color: t.textHint),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.title.trim().isEmpty ? '#${p.id}' : p.title.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: t.textPrimary),
                    ),
                  ),
                  if (onOpen != null)
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: t.textHint),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  final VoidCallback onLog;
  const _HistoryEmpty({required this.onLog});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: t.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded, size: 15, color: t.textHint),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.clientsHistoryEmpty,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.clientsHistoryEmptyHint,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        height: 1.45,
                        color: t.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppGhostButton(
          label: l10n.clientsLogFirstContact,
          onPressed: onLog,
          height: AppMetrics.minHitTarget,
          fontSize: 12.5,
        ),
      ],
    );
  }
}

class _HistoryProblem extends StatelessWidget {
  final VoidCallback onRetry;
  const _HistoryProblem({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.clientsHistoryLoadFailed,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary),
          ),
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
      ],
    );
  }
}
