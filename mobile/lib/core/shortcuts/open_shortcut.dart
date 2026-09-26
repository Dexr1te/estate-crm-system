import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/quick_add/quick_add.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_sheet.dart';
import 'package:real_estate_crm/core/shortcuts/app_shortcuts.dart';
import 'package:real_estate_crm/core/utils/router.dart';

/// A shortcut starts from home: the dashboard goes underneath, so backing out
/// of the form or the search lands somewhere, and then the same form or sheet
/// the "+" in the app opens goes on top.
Future<void> openAppShortcut(GoRouter router, AppShortcut shortcut) async {
  router.go('/dashboard');
  await WidgetsBinding.instance.endOfFrame;
  final context = rootNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  switch (shortcut) {
    case AppShortcut.search:
      unawaited(context.push<Object?>('/search'));
    case AppShortcut.newClient:
      await runQuickAdd(context, QuickAddAction.client);
    case AppShortcut.newTask:
      await runQuickAdd(context, QuickAddAction.task);
    case AppShortcut.newMeeting:
      await runQuickAdd(context, QuickAddAction.meeting);
  }
}
