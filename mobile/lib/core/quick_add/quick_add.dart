import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything that can be started from the one "+" the app has.
enum QuickAddAction { client, listing, deal, meeting, task, logContact }

String quickAddLabel(AppLocalizations l10n, QuickAddAction action) =>
    switch (action) {
      QuickAddAction.client => l10n.quickAddClient,
      QuickAddAction.listing => l10n.quickAddListing,
      QuickAddAction.deal => l10n.quickAddDeal,
      QuickAddAction.meeting => l10n.quickAddMeeting,
      QuickAddAction.task => l10n.quickAddTask,
      QuickAddAction.logContact => l10n.quickAddLogContact,
    };

IconData quickAddIcon(QuickAddAction action) => switch (action) {
      QuickAddAction.client => Icons.person_add_alt_1_outlined,
      QuickAddAction.listing => Icons.home_work_outlined,
      QuickAddAction.deal => Icons.handshake_outlined,
      QuickAddAction.meeting => Icons.event_outlined,
      QuickAddAction.task => Icons.task_alt_rounded,
      QuickAddAction.logContact => Icons.phone_callback_outlined,
    };

/// What each role may start. The server lets every signed-in role create each
/// of these (only deleting is gated), so a role sees them all; nobody signed
/// in sees nothing.
List<QuickAddAction> quickAddActionsFor(Role? role) =>
    role == null ? const [] : QuickAddAction.values;

/// What the screen underneath the "+" is about, read off its route: a record
/// the new one should be linked to, or the list tab whose own "+" this
/// replaced.
class QuickAddScope {
  final int? clientId;
  final int? dealId;
  final int? propertyId;
  final QuickAddAction? tab;

  const QuickAddScope({this.clientId, this.dealId, this.propertyId, this.tab});

  static const none = QuickAddScope();

  bool get hasRecord =>
      clientId != null || dealId != null || propertyId != null;

  factory QuickAddScope.fromLocation(String location) {
    final segments = Uri.parse(location).pathSegments;
    if (segments.isEmpty) return none;
    const tabs = {
      'clients': QuickAddAction.client,
      'properties': QuickAddAction.listing,
      'deals': QuickAddAction.deal,
      'meetings': QuickAddAction.meeting,
    };
    if (segments.length == 1) return QuickAddScope(tab: tabs[segments.first]);
    final id = int.tryParse(segments[1]);
    if (id == null || segments.length > 2) return none;
    return switch (segments.first) {
      'clients' => QuickAddScope(clientId: id),
      'deals' => QuickAddScope(dealId: id),
      'properties' => QuickAddScope(propertyId: id),
      _ => none,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is QuickAddScope &&
      other.clientId == clientId &&
      other.dealId == dealId &&
      other.propertyId == propertyId &&
      other.tab == tab;

  @override
  int get hashCode => Object.hash(clientId, dealId, propertyId, tab);
}

/// The list tab's own action leads, as its old "+" did; otherwise whatever
/// was picked last time, so the usual thing is one reach away. The rest keep
/// their fixed order, so muscle memory survives.
List<QuickAddAction> orderQuickAdd(
  List<QuickAddAction> actions, {
  QuickAddAction? tab,
  QuickAddAction? lastUsed,
}) {
  final lead = <QuickAddAction>{
    for (final a in [tab, lastUsed])
      if (a != null && actions.contains(a)) a,
  };
  return [...lead, ...actions.where((a) => !lead.contains(a))];
}

/// The last action each person picked, kept on this phone.
class QuickAddMemory {
  QuickAddMemory._();

  static String _key(int userId) => 'quick_add_last_$userId';

  static Future<QuickAddAction?> read(int? userId) async {
    if (userId == null) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_key(userId));
      for (final a in QuickAddAction.values) {
        if (a.name == name) return a;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> write(int? userId, QuickAddAction action) async {
    if (userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(userId), action.name);
    } catch (_) {}
  }
}
