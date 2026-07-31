import 'package:intl/intl.dart';

String formatPrice(double price) {
  if (price >= 1000000) return '\$${(price / 1000000).toStringAsFixed(1)}M';
  if (price >= 1000) return '\$${NumberFormat('#,##0', 'en_US').format(price)}';
  return '\$${price.toStringAsFixed(0)}';
}

String formatDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);
String formatDateTime(DateTime dt) =>
    DateFormat('MMM d, yyyy • h:mm a').format(dt);

String formatTimeOfDay(DateTime dt) => DateFormat('HH:mm').format(dt);

String formatWeekdayDate(DateTime dt, String locale) =>
    DateFormat.MMMEd(_resolveLocale(locale)).format(dt);

String formatDayMonth(DateTime dt, String locale) =>
    DateFormat.MMMd(_resolveLocale(locale)).format(dt);

String _resolveLocale(String locale) =>
    DateFormat.localeExists(locale) ? locale : 'en';

bool isSameDay(DateTime dt, DateTime other) =>
    dt.year == other.year && dt.month == other.month && dt.day == other.day;
