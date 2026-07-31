import 'package:intl/intl.dart';

String formatPrice(double price) {
  if (price >= 1000000) return '\$${(price / 1000000).toStringAsFixed(1)}M';
  if (price >= 1000) return '\$${NumberFormat('#,##0', 'en_US').format(price)}';
  return '\$${price.toStringAsFixed(0)}';
}

String formatDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);
String formatDateTime(DateTime dt) =>
    DateFormat('MMM d, yyyy • h:mm a').format(dt);

/// 24-hour clock, as drawn in the mocks (19:40).
String formatTimeOfDay(DateTime dt) => DateFormat('HH:mm').format(dt);

/// Weekday + day + month in the active locale, e.g. "Tue, Jul 29".
String formatWeekdayDate(DateTime dt, String locale) =>
    DateFormat.MMMEd(_resolveLocale(locale)).format(dt);

/// Day + month in the active locale, e.g. "31 July" — the meetings-list group
/// header.
String formatDayMonth(DateTime dt, String locale) =>
    DateFormat.MMMd(_resolveLocale(locale)).format(dt);

/// Falls back to English when `intl` has no date symbols for the UI locale, so
/// a missing locale degrades to English month names instead of throwing.
String _resolveLocale(String locale) =>
    DateFormat.localeExists(locale) ? locale : 'en';

/// True when [dt] falls on the same calendar day as [other].
bool isSameDay(DateTime dt, DateTime other) =>
    dt.year == other.year && dt.month == other.month && dt.day == other.day;
