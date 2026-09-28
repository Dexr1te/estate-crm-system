import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';

/// Spaces in expectations stand for the non-breaking ones [formatMoney] writes.
String nb(String s) => s.replaceAll(' ', nbsp);

void main() {
  String full(double v, Currency c, String l) => formatMoney(v, c, l);
  String short(double v, Currency c, String l) =>
      formatMoney(v, c, l, compact: true);

  group('formatMoney, full', () {
    test('English: dollars and euros lead, the rest follow', () {
      expect(full(0, Currency.usd, 'en'), r'$0');
      expect(full(999, Currency.usd, 'en'), r'$999');
      expect(full(1000, Currency.usd, 'en'), r'$1,000');
      expect(full(12500000, Currency.usd, 'en'), r'$12,500,000');
      expect(full(1200000000, Currency.eur, 'en'), '€1,200,000,000');
      expect(full(12500000, Currency.kzt, 'en'), nb('12,500,000 ₸'));
      expect(full(1000, Currency.rub, 'en'), nb('1,000 ₽'));
      expect(full(12500000, Currency.uzs, 'en'), nb('12,500,000 UZS'));
      expect(full(999, Currency.kgs, 'en'), nb('999 KGS'));
    });

    test('Russian and Kazakh: spaces between groups, every sign after', () {
      for (final l in ['ru', 'kk']) {
        expect(full(0, Currency.kzt, l), nb('0 ₸'));
        expect(full(999, Currency.kzt, l), nb('999 ₸'));
        expect(full(1000, Currency.kzt, l), nb('1 000 ₸'));
        expect(full(12500000, Currency.kzt, l), nb('12 500 000 ₸'));
        expect(full(1200000000, Currency.rub, l), nb('1 200 000 000 ₽'));
        expect(full(12500000, Currency.usd, l), nb(r'12 500 000 $'));
        expect(full(1000, Currency.eur, l), nb('1 000 €'));
        expect(full(12500000, Currency.uzs, l), nb('12 500 000 сум'));
        expect(full(1000, Currency.kgs, l), nb('1 000 сом'));
      }
    });

    test('a region in the locale does not change the rules', () {
      expect(full(1000, Currency.kzt, 'ru_KZ'), nb('1 000 ₸'));
      expect(full(1000, Currency.usd, 'en-US'), r'$1,000');
      expect(full(1000, Currency.usd, 'de'), r'$1,000',
          reason: 'a language the app does not speak reads as English');
    });

    test('cents only when there are some, and only under a thousand', () {
      expect(full(999.5, Currency.usd, 'en'), r'$999.50');
      expect(full(12.05, Currency.kzt, 'ru'), nb('12,05 ₸'));
      expect(full(12.0, Currency.kzt, 'ru'), nb('12 ₸'));
      expect(full(1234.56, Currency.usd, 'en'), r'$1,235');
      expect(full(1234.4, Currency.kzt, 'kk'), nb('1 234 ₸'));
      expect(full(0.004, Currency.usd, 'en'), r'$0');
    });

    test('a negative amount carries its minus in front', () {
      expect(full(-1500, Currency.usd, 'en'), r'-$1,500');
      expect(full(-1500, Currency.kzt, 'ru'), nb('-1 500 ₸'));
    });
  });

  group('formatMoney, compact', () {
    test('English keeps the one decimal it always showed', () {
      expect(short(0, Currency.usd, 'en'), r'$0');
      expect(short(999, Currency.usd, 'en'), r'$999');
      expect(short(1000, Currency.usd, 'en'), r'$1,000');
      expect(short(999999, Currency.usd, 'en'), r'$999,999');
      expect(short(12500000, Currency.usd, 'en'), r'$12.5M');
      expect(short(28000000, Currency.usd, 'en'), r'$28.0M');
      expect(short(1200000000, Currency.usd, 'en'), r'$1.2B');
      expect(short(12500000, Currency.eur, 'en'), '€12.5M');
      expect(short(12500000, Currency.kzt, 'en'), nb('12.5M ₸'));
      expect(short(1200000000, Currency.uzs, 'en'), nb('1.2B UZS'));
    });

    test('Russian and Kazakh write млн and млрд and drop a trailing zero', () {
      for (final l in ['ru', 'kk']) {
        expect(short(12500000, Currency.kzt, l), nb('12,5 млн ₸'));
        expect(short(28000000, Currency.kzt, l), nb('28 млн ₸'));
        expect(short(1200000000, Currency.kzt, l), nb('1,2 млрд ₸'));
        expect(short(12500000, Currency.rub, l), nb('12,5 млн ₽'));
        expect(short(12500000, Currency.usd, l), nb(r'12,5 млн $'));
        expect(short(12500000, Currency.kgs, l), nb('12,5 млн сом'));
        expect(short(850000, Currency.kzt, l), nb('850 000 ₸'));
      }
    });

    test('a million that rounds up to a thousand becomes a billion', () {
      expect(short(999960000, Currency.usd, 'en'), r'$1.0B');
      expect(short(999960000, Currency.kzt, 'ru'), nb('1 млрд ₸'));
    });
  });

  group('Currency.fromCode', () {
    test('reads every code and falls back to dollars', () {
      for (final c in Currency.values) {
        expect(Currency.fromCode(c.code), c);
      }
      expect(Currency.fromCode(null), Currency.usd);
      expect(Currency.fromCode('GBP'), Currency.usd);
    });
  });

  group('formatPrice follows AppCurrency', () {
    test('dollars in English until told otherwise', () {
      expect(AppCurrency.current, Currency.usd);
      expect(formatPrice(12500000), r'$12.5M');
      expect(formatPrice(1234), r'$1,234');
    });

    test('switches with the holder and its language', () {
      AppCurrency.set(Currency.kzt);
      expect(formatPrice(12500000), nb('12.5M ₸'));
      AppCurrency.locale = 'ru';
      expect(formatPrice(12500000), nb('12,5 млн ₸'));
      expect(formatPrice(1234), nb('1 234 ₸'));
      AppCurrency.setCode('RUB');
      expect(formatPrice(1234), nb('1 234 ₽'));
    });

    test('reset goes back to dollars and keeps the language', () {
      AppCurrency.set(Currency.kzt);
      AppCurrency.locale = 'kk';
      AppCurrency.reset();
      expect(formatPrice(1234), nb(r'1 234 $'));
    });
  });
}
