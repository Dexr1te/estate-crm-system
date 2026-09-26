import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The screen on show carries the app's one "+", and no second one beside it.
void expectOneQuickAdd() {
  expect(find.byKey(const ValueKey('quick-add')), findsOneWidget,
      reason: 'the quick-add "+" is missing from this screen');
  expect(find.byIcon(Icons.add_rounded), findsOneWidget,
      reason: 'a second "+" on the same screen');
  expect(find.byIcon(Icons.add), findsNothing,
      reason: 'a second "+" on the same screen');
}
