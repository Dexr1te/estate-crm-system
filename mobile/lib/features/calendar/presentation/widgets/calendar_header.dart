import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "October 2026", from the standalone month name so Russian and Kazakh read
/// in the nominative, capitalised the way a heading is.
String calendarMonthTitle(DateTime month, String locale) {
  final text = DateFormat('LLLL y', locale).format(month);
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

class CalendarHeader extends StatelessWidget {
  final DateTime month;
  final bool collapsed;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggleCollapsed;

  const CalendarHeader({
    super.key,
    required this.month,
    required this.collapsed,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Row(
      children: [
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            calendarMonthTitle(month, locale),
            key: const ValueKey('calendar-month-title'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: t.textPrimary),
          ),
        ),
        AppIconTile(
          key: const ValueKey('calendar-collapse'),
          icon:
              collapsed ? Icons.unfold_more_rounded : Icons.unfold_less_rounded,
          tooltip: collapsed ? l10n.calendarShowMonth : l10n.calendarShowWeek,
          onPressed: onToggleCollapsed,
        ),
        AppIconTile(
          key: const ValueKey('calendar-previous'),
          icon: Icons.chevron_left_rounded,
          tooltip: collapsed
              ? l10n.calendarPreviousWeek
              : l10n.calendarPreviousMonth,
          onPressed: onPrevious,
        ),
        AppIconTile(
          key: const ValueKey('calendar-next'),
          icon: Icons.chevron_right_rounded,
          tooltip: collapsed ? l10n.calendarNextWeek : l10n.calendarNextMonth,
          onPressed: onNext,
        ),
      ],
    );
  }
}
