import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The "next meeting" hero — the same card the meetings list uses at the top
/// of its own screen.
///
/// Light: navy fill with white text. Dark: bordered surface. The gold time
/// chip, title, meta line and the filled/ghost action pair are identical in
/// both.
class NextMeetingHero extends StatelessWidget {
  final MeetingResponse meeting;
  final String eyebrow;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const NextMeetingHero({
    super.key,
    required this.meeting,
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
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();

    final meta = [
      if (meeting.clientName.isNotEmpty) meeting.clientName,
      if (meeting.agentName.isNotEmpty) l10n.dashboardAgentMeta(meeting.agentName),
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
        ],
      ),
    );
  }
}

/// Gold chip holding the start time, with the day beneath it. (The API carries
/// no duration, so the second line marks the day instead.)
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
            dayLabel(l10n, at, DateTime.now(), locale),
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

/// "now" / "in 25 min" / "in 3 h" / "tomorrow" / a date, whichever is the most
/// useful at this distance.
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

/// "today" / "tomorrow" / "31 Jul" — the day a meeting falls on.
String dayLabel(
    AppLocalizations l10n, DateTime at, DateTime now, String locale) {
  if (isSameDay(at, now)) return l10n.dashboardRelativeToday;
  if (isSameDay(at, now.add(const Duration(days: 1)))) {
    return l10n.dashboardRelativeTomorrow;
  }
  return formatDayMonth(at, locale);
}
