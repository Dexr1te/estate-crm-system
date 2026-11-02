import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

final AppLocalizations _en = AppLocalizationsEn();

String _label(DateTime due, DateTime now) => dueLabel(_en, due, now, 'en');

void main() {
  setUpAll(initializeDateFormatting);

  group('due label', () {
    final now = DateTime(2026, 7, 31, 14);

    test('says today and tomorrow, then the date', () {
      expect(_label(DateTime(2026, 7, 31, 18), now), startsWith('Today, '));
      expect(_label(DateTime(2026, 8, 1, 9), now), startsWith('Tomorrow, '));
      expect(_label(DateTime(2026, 8, 2, 9), now), isNot(contains('Tomorrow')));
    });

    // Clocks in the US spring forward on 8 March 2026, so that local day is
    // 23 hours long. Run with TZ=America/New_York to see it bite.
    test('counts calendar days across a clock change', () {
      final monday = DateTime(2026, 3, 9, 10);
      expect(
          _label(monday, DateTime(2026, 3, 8, 14)), startsWith('Tomorrow, '));
      expect(_label(monday, DateTime(2026, 3, 7, 14)),
          isNot(contains('Tomorrow')));
    });
  });
}
