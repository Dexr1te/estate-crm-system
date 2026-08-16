import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/day_rail.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/core/utils/clock.dart';

class NextMeetingHero extends StatelessWidget {
  final MeetingResponse meeting;
  final List<MeetingResponse> dayMeetings;
  final String eyebrow;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const NextMeetingHero({
    super.key,
    required this.meeting,
    this.dayMeetings = const [],
    required this.eyebrow,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final now = AppClock.now();
    final locale = Localizations.localeOf(context).toLanguageTag();

    final meta = [
      if (meeting.clientName.isNotEmpty) meeting.clientName,
      if (meeting.agentName.isNotEmpty)
        l10n.dashboardAgentMeta(meeting.agentName),
    ].join(' · ');

    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: EyebrowLabel(eyebrow)),
              const SizedBox(width: 8),
              Text(
                relativeTimeLabel(l10n, meeting.scheduledAt, now, locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: t.heroTextMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimeChip(at: meeting.scheduledAt),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: t.heroText),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 12,
                            color: t.heroTextMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppFilledButton(
                  label: primaryLabel,
                  onPressed: onPrimary,
                  height: AppMetrics.minHitTarget,
                  fontSize: 12.5,
                  radius: 11,
                  fill: t.heroActionFill,
                  labelColor: t.heroActionLabel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppGhostButton(
                  label: secondaryLabel,
                  onPressed: onSecondary,
                  height: AppMetrics.minHitTarget,
                  fontSize: 12.5,
                  borderColor: t.heroGhostBorder,
                  labelColor: t.heroText,
                ),
              ),
            ],
          ),
          if (dayMeetings.isNotEmpty)
            DayRail(
              meetings: dayMeetings,
              now: now,
              focusId: meeting.id,
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final DateTime at;
  const _TimeChip({required this.at});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      constraints: const BoxConstraints(minWidth: 62),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: t.accent,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatTimeOfDay(at),
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w700,
                color: t.onAccent),
          ),
          const SizedBox(height: 3),
          Text(
            dayLabel(l10n, at, AppClock.now(), locale),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: t.onAccent.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }
}

String relativeTimeLabel(
    AppLocalizations l10n, DateTime at, DateTime now, String locale) {
  final diff = at.difference(now);
  if (diff.isNegative || diff.inMinutes < 1) return l10n.dashboardRelativeNow;
  if (diff.inMinutes < 60) {
    return l10n.dashboardRelativeInMinutes(diff.inMinutes);
  }
  if (isSameDay(at, now)) return l10n.dashboardRelativeInHours(diff.inHours);
  if (isSameDay(at, now.add(const Duration(days: 1)))) {
    return l10n.dashboardRelativeTomorrow;
  }
  return formatDayMonth(at, locale);
}

String dayLabel(
    AppLocalizations l10n, DateTime at, DateTime now, String locale) {
  if (isSameDay(at, now)) return l10n.dashboardRelativeToday;
  if (isSameDay(at, now.add(const Duration(days: 1)))) {
    return l10n.dashboardRelativeTomorrow;
  }
  return formatDayMonth(at, locale);
}
