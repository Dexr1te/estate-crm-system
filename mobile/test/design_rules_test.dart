import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('/l10n/'))
      .toList();

  final arbFiles = Directory('lib/l10n')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList();

  test('no emoji in user-facing copy', () {
    final emoji = RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}]',
        unicode: true);

    for (final f in arbFiles) {
      final offenders =
          f.readAsLinesSync().where((l) => emoji.hasMatch(l)).toList();
      expect(offenders, isEmpty, reason: '${f.path} contains emoji');
    }
  });

  test('the typeface is referenced through AppFonts, never hardcoded', () {
    final hardcoded = RegExp(r"fontFamily: '(?!monospace)");
    for (final f in libFiles) {
      if (f.path.endsWith('app_fonts.dart')) continue;
      expect(hardcoded.hasMatch(f.readAsStringSync()), isFalse,
          reason: '${f.path} hardcodes a font family; use AppFonts.sans');
    }
  });

  test('the removed blue accent is gone', () {
    for (final f in libFiles) {
      final code = f
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n')
          .toUpperCase();
      expect(code.contains('5B8FE8'), isFalse,
          reason: '${f.path} still uses the retired blue accent');
    }
  });

  test('every ARB carries the same key set', () {
    final keySets = {
      for (final f in arbFiles)
        f.path: RegExp(r'^\s*"([^"@][^"]*)":')
            .allMatches(f.readAsStringSync())
            .map((m) => m.group(1)!)
            .toSet(),
    };
    final reference = keySets.values.first;
    for (final entry in keySets.entries) {
      expect(entry.value.difference(reference), isEmpty,
          reason: '${entry.key} has keys the template lacks');
      expect(reference.difference(entry.value), isEmpty,
          reason: '${entry.key} is missing keys');
    }
  });
}
