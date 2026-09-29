import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/launch_gate.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What a long press on the app icon offers.
enum AppShortcut {
  newClient('new_client'),
  newTask('new_task'),
  newMeeting('new_meeting'),
  search('search');

  const AppShortcut(this.type);
  final String type;

  static AppShortcut? parse(String? type) {
    for (final s in values) {
      if (s.type == type) return s;
    }
    return null;
  }
}

String appShortcutTitle(AppLocalizations l10n, AppShortcut shortcut) =>
    switch (shortcut) {
      AppShortcut.newClient => l10n.quickAddClient,
      AppShortcut.newTask => l10n.quickAddTask,
      AppShortcut.newMeeting => l10n.quickAddMeeting,
      AppShortcut.search => l10n.searchTitle,
    };

List<ShortcutItem> appShortcutItems(AppLocalizations l10n) => [
      for (final s in AppShortcut.values)
        ShortcutItem(type: s.type, localizedTitle: appShortcutTitle(l10n, s)),
    ];

/// Takes the shortcut the app was opened with, or tapped while it ran, and
/// opens it once the saved session is known. Someone signed out, or still
/// waiting for a team, goes through the usual screens and the shortcut is
/// dropped: it would only be waiting behind a login they may never finish.
class ShortcutHandler {
  ShortcutHandler({
    required QuickActions actions,
    required AuthBloc auth,
    required void Function(AppShortcut shortcut) open,
    LaunchGate? gate,
  })  : _actions = actions,
        _gate = gate,
        _auth = auth,
        _open = open;

  final QuickActions _actions;
  final AuthBloc _auth;
  final void Function(AppShortcut shortcut) _open;

  /// A shortcut pressed while the app is locked waits for the PIN.
  final LaunchGate? _gate;

  AppShortcut? _pending;
  String? _titlesLocale;
  bool _disposed = false;

  Future<void> start() async {
    _auth.addListener(_flush);
    _gate?.addListener(_flush);
    try {
      await _actions.initialize(_onAction);
    } catch (_) {}
  }

  void _onAction(String type) {
    final shortcut = AppShortcut.parse(type);
    if (shortcut == null || _disposed) return;
    _pending = shortcut;
    _flush();
  }

  void _flush() {
    final shortcut = _pending;
    if (shortcut == null || !_auth.isSessionResolved) return;
    if (!(_gate?.isOpen ?? true)) return;
    _pending = null;
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.teamId == null && user.role != Role.ADMIN) return;
    _open(shortcut);
  }

  /// Puts the titles in [l10n]'s language on the icon; a repeat for the same
  /// language is not sent again.
  Future<void> setTitles(AppLocalizations l10n) async {
    if (_disposed || _titlesLocale == l10n.localeName) return;
    _titlesLocale = l10n.localeName;
    try {
      await _actions.setShortcutItems(appShortcutItems(l10n));
    } catch (_) {
      _titlesLocale = null;
    }
  }

  void dispose() {
    _disposed = true;
    _auth.removeListener(_flush);
    _gate?.removeListener(_flush);
  }
}

/// Keeps the icon's shortcut titles in the app's language, whichever way it
/// was chosen and whenever it changes.
class ShortcutTitles extends StatefulWidget {
  final ShortcutHandler handler;
  final Widget child;

  const ShortcutTitles({super.key, required this.handler, required this.child});

  @override
  State<ShortcutTitles> createState() => _ShortcutTitlesState();
}

class _ShortcutTitlesState extends State<ShortcutTitles> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(widget.handler.setTitles(AppLocalizations.of(context)));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
