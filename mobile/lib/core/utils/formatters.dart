import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/utils/money.dart';

export 'package:real_estate_crm/core/utils/money.dart';

/// A price in the signed-in agency's currency and the app's language:
/// `$12.5M`, `$1,234` in English with dollars, `12,5 млн ₸`, `1 234 ₸` in
/// Russian with tenge. See [formatMoney] for the rules and [AppCurrency] for
/// where the currency comes from.
String formatPrice(double price) => formatMoney(
      price,
      AppCurrency.current,
      AppCurrency.locale,
      compact: true,
    );

String formatRate(double rate) =>
    rate.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

String formatDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);
String formatDateTime(DateTime dt) =>
    DateFormat('MMM d, yyyy • h:mm a').format(dt);

String formatTimeOfDay(DateTime dt) => DateFormat('HH:mm').format(dt);

String formatWeekdayDate(DateTime dt, String locale) =>
    DateFormat.MMMEd(_resolveLocale(locale)).format(dt);

String formatDayMonth(DateTime dt, String locale) =>
    DateFormat.MMMd(_resolveLocale(locale)).format(dt);

String formatFullDate(DateTime dt, String locale) =>
    DateFormat.yMMMd(_resolveLocale(locale)).format(dt);

String formatMonthShort(DateTime dt, String locale) =>
    DateFormat.MMM(_resolveLocale(locale)).format(dt);

String _resolveLocale(String locale) =>
    DateFormat.localeExists(locale) ? locale : 'en';

bool isSameDay(DateTime dt, DateTime other) =>
    dt.year == other.year && dt.month == other.month && dt.day == other.day;
