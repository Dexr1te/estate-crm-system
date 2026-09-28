import 'package:flutter/foundation.dart';

/// The currencies an agency can price its listings in (ISO 4217).
///
/// Amounts carry no currency of their own — a price is just a number — so
/// this only decides which sign is printed next to it and where.
enum Currency {
  kzt('KZT', '₸', '₸'),
  rub('RUB', '₽', '₽'),
  usd('USD', r'$', r'$'),
  eur('EUR', '€', '€'),
  uzs('UZS', 'UZS', 'сум'),
  kgs('KGS', 'KGS', 'сом');

  const Currency(this.code, this._englishSign, this._localSign);

  final String code;
  final String _englishSign;
  final String _localSign;

  /// The code the server sent, or dollars for anything unknown — what every
  /// agency saw before it could choose.
  static Currency fromCode(String? code) {
    for (final c in values) {
      if (c.code == code) return c;
    }
    return usd;
  }

  /// "₸" everywhere; "сум" in Russian and Kazakh but "UZS" in English.
  String sign(String locale) =>
      _isEnglish(_language(locale)) ? _englishSign : _localSign;

  /// Only dollars and euros lead, and only in English: "$1,200", "€1,200",
  /// but "1,200 ₸" and "1 200 $".
  bool _leads(String language) =>
      _isEnglish(language) && (this == usd || this == eur);
}

/// Keeps a sign or a unit on the same line as its number.
const nbsp = ' ';

String _language(String locale) => locale.split(RegExp('[-_]')).first;

bool _isEnglish(String language) => language != 'ru' && language != 'kk';

/// An amount as people in [locale] write money in [currency].
///
/// * English groups by commas: `$1,234`, `1,234 ₸`, `12,500,000 UZS`.
/// * Russian and Kazakh group by spaces and put every sign after the number:
///   `1 234 ₸`, `12 500 000 $`.
/// * Whole amounts print no decimals; an amount under a thousand with cents
///   prints two (`$999.50`, `12,50 ₸`); from a thousand up it is rounded to
///   whole units.
/// * [compact] shortens millions and billions: `$12.5M`, `$1.2B` in English,
///   `12,5 млн ₸`, `1,2 млрд ₸` in Russian and Kazakh. English keeps the one
///   decimal (`$28.0M`) as the app always has; Russian and Kazakh drop a
///   trailing zero (`28 млн ₸`). Below a million [compact] changes nothing.
///
/// Every space it writes is a non-breaking one ([nbsp]).
String formatMoney(
  double amount,
  Currency currency,
  String locale, {
  bool compact = false,
}) {
  final language = _language(locale);
  final english = _isEnglish(language);
  final minus = amount < 0 ? '-' : '';
  final a = amount.abs();

  final String number;
  if (compact && a >= 1e6) {
    final millions = _roundTenth(a / 1e6);
    final billions = millions >= 1000;
    final value = billions ? _roundTenth(a / 1e9) : millions;
    final unit = english ? (billions ? 'B' : 'M') : (billions ? 'млрд' : 'млн');
    var digits = value.toStringAsFixed(1);
    if (english) {
      number = '$digits$unit';
    } else {
      if (digits.endsWith('.0')) {
        digits = digits.substring(0, digits.length - 2);
      }
      number = '${digits.replaceAll('.', ',')}$nbsp$unit';
    }
  } else {
    number = _full(a, english);
  }

  final sign = currency.sign(locale);
  return currency._leads(language)
      ? '$minus$sign$number'
      : '$minus$number$nbsp$sign';
}

double _roundTenth(double v) => (v * 10).roundToDouble() / 10;

String _full(double a, bool english) {
  final group = english ? ',' : nbsp;
  final cents = a < 1000 ? a.toStringAsFixed(2) : null;
  if (cents != null && !cents.endsWith('.00')) {
    final whole = cents.substring(0, cents.length - 3);
    return '$whole${english ? '.' : ','}${cents.substring(cents.length - 2)}';
  }
  final digits = a.round().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(group);
    out.write(digits[i]);
  }
  return out.toString();
}

/// The one place the app keeps the signed-in agency's currency, and the
/// language money is written in.
///
/// Set from the session on sign-in and on every `/auth/me` refresh, and from
/// the team screen when a manager changes it; back to dollars on sign-out.
/// [formatPrice] reads it, so no screen has to pass a currency around. The app
/// root listens and rebuilds everything when it changes.
class AppCurrency {
  AppCurrency._();

  static final ValueNotifier<Currency> notifier =
      ValueNotifier<Currency>(Currency.usd);

  static Currency get current => notifier.value;

  static void set(Currency currency) => notifier.value = currency;

  static void setCode(String? code) => set(Currency.fromCode(code));

  /// Back to dollars, as on sign-out. The language stays: it is the app's,
  /// not the account's.
  static void reset() => notifier.value = Currency.usd;

  /// The app's language code; the root keeps it in step with the UI.
  static String locale = 'en';
}
