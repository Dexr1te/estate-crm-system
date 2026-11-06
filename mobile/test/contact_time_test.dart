import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

final AppLocalizations _en = AppLocalizationsEn();

void main() {
  setUpAll(initializeDateFormatting);

  final now = DateTime(2026, 7, 31, 14);

  test('a client card says today, yesterday, then how many days ago', () {
    String label(DateTime at) => lastContactLabel(_en, at, now, 'en');
    expect(label(DateTime(2026, 7, 31, 9)), 'Contacted today');
    expect(label(DateTime(2026, 7, 30, 18)), 'Contacted yesterday');
    expect(label(DateTime(2026, 7, 21, 18)), 'Contacted 10 days ago');
  });

  test('the history says today and yesterday, then the date', () {
    String label(DateTime at) => activityTimeLabel(_en, at, now, 'en');
    expect(label(DateTime(2026, 7, 31, 9)), startsWith('Today, '));
    expect(label(DateTime(2026, 7, 30, 18)), startsWith('Yesterday, '));
    expect(label(DateTime(2026, 7, 29, 18)), isNot(contains('Yesterday')));
  });

  // Clocks in the US spring forward on 8 March 2026, so that local day is 23
  // hours long. Run with TZ=America/New_York to see it bite: a call on the
  // Sunday read "today" on the Monday, and every contact from before the
  // change read a day short for a month.
  test('counts calendar days across a clock change', () {
    final monday = DateTime(2026, 3, 9, 10);
    final sunday = DateTime(2026, 3, 8, 15);
    expect(lastContactLabel(_en, sunday, monday, 'en'), 'Contacted yesterday');
    expect(activityTimeLabel(_en, sunday, monday, 'en'),
        startsWith('Yesterday, '));
    expect(
        lastContactLabel(
            _en, DateTime(2026, 3, 1, 15), DateTime(2026, 3, 20, 10), 'en'),
        'Contacted 19 days ago');
  });
}
