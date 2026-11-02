import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';

void main() {
  late List<Uri> opened;

  setUp(() {
    opened = [];
    ContactActions.opener = (uri, _) async {
      opened.add(uri);
      return true;
    };
  });
  tearDown(ContactActions.resetOpener);

  group('WhatsApp', () {
    for (final (typed, path) in [
      ('+7 916 220-84-11', '/79162208411'),
      ('8 701 123 45 67', '/77011234567'),
      ('8 (916) 220-84-11', '/79162208411'),
      ('+84 91 234 5678', '/84912345678'),
      ('+1 415 555 0100', '/14155550100'),
    ]) {
      test('"$typed" opens wa.me$path', () async {
        expect(await ContactActions.whatsApp(typed, 'Hello'), isTrue);
        expect(opened.single.host, 'wa.me');
        expect(opened.single.path, path);
      });
    }

    test('no number opens nothing', () async {
      expect(await ContactActions.whatsApp(' - ', 'Hello'), isFalse);
      expect(opened, isEmpty);
    });
  });
}
