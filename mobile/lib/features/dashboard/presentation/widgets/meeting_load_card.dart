import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Meetings per day over the next two weeks, as columns.
///
/// Answers "how busy am I about to be", which no other block on the dashboard
/// does — the metric card gives one total and the list only shows the next
/// four. Today is marked so the run of columns has an anchor.
class MeetingLoadCard extends StatelessWidget {
  /// One count per day, index 0 = today.
  final List<int> load;
  final DateTime today;
  final VoidCallback onTap;

  const MeetingLoadCard({
    super.key,
    required this.load,
    required this.today,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final peak = load.fold<int>(0, (a, b) => b > a ? b : a);
    final total = load.fold<int>(0, (a, b) => a + b);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: EyebrowLabel(l10n.dashboardMeetingLoad)),
                const SizedBox(width: 8),
                Text(
                  l10n.dashboardLoadTotal(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < load.length; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Expanded(
                      child: _Column(
                        count: load[i],
                        peak: peak,
                        isToday: i == 0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(
                  l10n.dashboardToday,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    formatDayMonth(
                        today.add(Duration(days: load.length - 1)), locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 10.5,
                        color: t.textHint),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Column extends StatelessWidget {
  final int count;
  final int peak;
  final bool isToday;
  const _Column(
      {required this.count, required this.peak, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Empty days keep a 3px stub of track so the two-week rhythm stays legible
    // instead of collapsing into gaps.
    final fraction = peak == 0 ? 0.0 : count / peak;
    final filled = count > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: filled ? fraction.clamp(0.18, 1.0) : 0.06,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: filled
                    ? (isToday ? t.accent : t.chartLead)
                    : t.chartTrack,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
