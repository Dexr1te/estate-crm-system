import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One absence: whose (on the team's list), why, the days, who covers, and
/// a warning when meetings still sit on those days.
class TimeOffRow extends StatelessWidget {
  final TimeOff timeOff;
  final VoidCallback onTap;

  /// Leads with the person's name rather than the kind of time off.
  final bool showPerson;

  const TimeOffRow({
    super.key,
    required this.timeOff,
    required this.onTap,
    this.showPerson = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final kind = timeOffKindLabel(l10n, timeOff.kind);
    final period =
        timeOffPeriodLabel(timeOff.startDate, timeOff.endDate, now, locale);
    final title = showPerson ? timeOffPersonLabel(l10n, timeOff) : kind;
    final when = [
      if (showPerson) kind,
      period,
      l10n.timeOffDays(timeOff.days),
    ].join(' · ');
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11.5, color: t.textSecondary);

    return AppCard(
      key: ValueKey('time-off-row-${timeOff.id}'),
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.surfaceVariant,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(timeOffKindIcon(timeOff.kind),
                size: 19, color: t.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: t.textPrimary)),
                    ),
                    if (timeOff.current) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: StatusChip(
                            label: l10n.timeOffAwayNow,
                            hue: StatusHue.negotiation),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(when,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: t.textPrimary)),
                const SizedBox(height: 2),
                Text(timeOffCoverLabel(l10n, timeOff.coverName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: secondary),
                if (timeOff.conflictCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(l10n.timeOffConflictsCount(timeOff.conflictCount),
                      key: ValueKey('time-off-conflicts-${timeOff.id}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: secondary.copyWith(color: t.dangerText)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The person's name, or a stand-in when the server sent none.
String timeOffPersonLabel(AppLocalizations l10n, TimeOff t) =>
    t.userName.trim().isEmpty ? l10n.notificationsSomeone : t.userName;

/// The skeleton of a [TimeOffRow], shaped like one.
class TimeOffRowBone extends StatelessWidget {
  const TimeOffRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 38, height: 38, radius: 11),
          titleFactor: 0.5,
          subtitleFactor: 0.65,
        ),
      );
}
