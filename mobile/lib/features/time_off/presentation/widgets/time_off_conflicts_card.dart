import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The meetings the absent person still has on their days off: a warning,
/// nothing is moved or refused. Each opens its meeting; a colleague who may
/// not see them is told only how many. [onHandOver], when given, leads to
/// handing the person's work to somebody else.
class TimeOffConflictsCard extends StatelessWidget {
  final TimeOff timeOff;
  final ValueChanged<int> onOpenMeeting;
  final VoidCallback? onHandOver;

  const TimeOffConflictsCard({
    super.key,
    required this.timeOff,
    required this.onOpenMeeting,
    this.onHandOver,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final secondary = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11.5,
        height: 1.4,
        color: t.textSecondary);

    return AppCard(
      key: const ValueKey('time-off-conflicts'),
      borderColor: t.dangerBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: t.dangerText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.timeOffConflictsCount(timeOff.conflictCount),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.timeOffConflictsHint,
              maxLines: 4, overflow: TextOverflow.ellipsis, style: secondary),
          for (final c in timeOff.conflicts) ...[
            const SizedBox(height: 8),
            AppCard(
              key: ValueKey('time-off-conflict-${c.meetingId}'),
              nested: true,
              radius: AppMetrics.radiusSm,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              onTap: () => onOpenMeeting(c.meetingId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                      [
                        '${timeOffDateLabel(c.scheduledAt, now, locale)} '
                            '${formatTimeOfDay(c.scheduledAt)}',
                        if (c.clientName?.isNotEmpty == true) c.clientName!,
                        if (c.propertyTitle?.isNotEmpty == true)
                          c.propertyTitle!,
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: secondary),
                ],
              ),
            ),
          ],
          if (onHandOver != null) ...[
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('time-off-hand-over'),
              label: l10n.timeOffHandOver,
              icon: Icons.swap_horiz_rounded,
              onPressed: onHandOver,
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ],
        ],
      ),
    );
  }
}
