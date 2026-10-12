import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/widgets/more_section.dart';

Future<void> openMore(WidgetTester tester) async {
  addTearDown(MoreSection.forgetAll);
  if (find.byKey(MoreSection.contentKey).evaluate().isNotEmpty) return;
  final toggle = find.byKey(MoreSection.toggleKey);
  await tester.ensureVisible(toggle);
  await tester.pump();
  await tester.tap(toggle);
  await tester.pump();
  await tester.pump(MoreSection.duration);
}

Future<void> openMoreIfAny(WidgetTester tester) async {
  if (find.byKey(MoreSection.toggleKey).evaluate().isEmpty) return;
  await openMore(tester);
  await tester.pumpAndSettle();
}
