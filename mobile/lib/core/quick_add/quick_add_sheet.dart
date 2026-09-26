import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/quick_add/quick_add.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_menu.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/log_contact_sheet.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The records a new one will be linked to, looked up from the ids on the
/// route. A lookup that fails leaves the id with no name: the form still links
/// it and shows the name once its own lists arrive.
class QuickAddLinks {
  final PickerItem? client;
  final PickerItem? deal;
  final int? propertyId;
  final String? label;

  const QuickAddLinks({this.client, this.deal, this.propertyId, this.label});

  static const none = QuickAddLinks();
}

Future<QuickAddLinks> resolveQuickAddLinks(QuickAddScope scope) async {
  if (scope.clientId != null) {
    final id = scope.clientId!;
    try {
      final c = await Injector.clientsRepository.getClient(id);
      return QuickAddLinks(
          client: PickerItem(id: id, title: c.fullName), label: c.fullName);
    } catch (_) {
      return QuickAddLinks(client: PickerItem(id: id, title: ''));
    }
  }
  if (scope.dealId != null) {
    final id = scope.dealId!;
    try {
      final d = await Injector.dealsRepository.getDeal(id);
      return QuickAddLinks(
        deal: PickerItem(id: id, title: d.title),
        client: PickerItem(id: d.clientId, title: d.clientName),
        propertyId: d.propertyId,
        label: d.title.isNotEmpty ? d.title : d.clientName,
      );
    } catch (_) {
      return QuickAddLinks(deal: PickerItem(id: id, title: ''));
    }
  }
  if (scope.propertyId != null) {
    final id = scope.propertyId!;
    try {
      final p = await Injector.propertiesRepository.getProperty(id);
      return QuickAddLinks(propertyId: id, label: p.title);
    } catch (_) {
      return QuickAddLinks(propertyId: id);
    }
  }
  return QuickAddLinks.none;
}

String? _currentLocation(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return null;
  return currentLocationOf(router).toString();
}

/// Opens the one "+" of the app: what to add, ordered for this person and
/// this screen, linked to the record underneath when there is one.
/// [onDone] runs once whatever was picked has finished, so the screen
/// underneath can show what was just added to it.
Future<void> showQuickAddSheet(
  BuildContext context, {
  QuickAddScope? scope,
  VoidCallback? onDone,
}) async {
  final user = context.read<AuthBloc>().currentUser;
  final actions = quickAddActionsFor(user?.role);
  if (actions.isEmpty) return;
  final l10n = AppLocalizations.of(context);
  final where =
      scope ?? QuickAddScope.fromLocation(_currentLocation(context) ?? '/');
  final links = where.hasRecord
      ? resolveQuickAddLinks(where)
      : Future.value(QuickAddLinks.none);
  final last = await QuickAddMemory.read(user?.userId);
  if (!context.mounted) return;

  final picked = await showAppBottomSheet<QuickAddAction>(
    context,
    title: l10n.quickAddTitle,
    builder: (sheet) => QuickAddMenu(
      actions: orderQuickAdd(actions, tab: where.tab, lastUsed: last),
      lastUsed: where.tab == null ? last : null,
      linkedTo: links.then((l) => l.label),
      onPick: (a) => Navigator.pop(sheet, a),
    ),
  );
  if (picked == null || !context.mounted) return;
  unawaited(QuickAddMemory.write(user?.userId, picked));
  final resolved = await links;
  if (!context.mounted) return;
  await runQuickAdd(context, picked, links: resolved, onDone: onDone);
}

String _withLinks(String path, Map<String, int?> ids) {
  final query = {
    for (final e in ids.entries)
      if (e.value != null) e.key: '${e.value}',
  };
  return Uri(path: path, queryParameters: query.isEmpty ? null : query)
      .toString();
}

/// Starts [action] from [context]: the same form or sheet its own screen
/// opens, with whatever [links] say it belongs to already filled in.
Future<void> runQuickAdd(
  BuildContext context,
  QuickAddAction action, {
  QuickAddLinks links = QuickAddLinks.none,
  VoidCallback? onDone,
}) async {
  void push(String location) =>
      unawaited(context.push<Object?>(location).then((_) => onDone?.call()));

  final clientId = links.client?.id;
  switch (action) {
    case QuickAddAction.client:
      push('/clients/new');
    case QuickAddAction.listing:
      push('/properties/new');
    case QuickAddAction.deal:
      push(_withLinks('/deals/new',
          {'clientId': clientId, 'propertyId': links.propertyId}));
    case QuickAddAction.meeting:
      push(_withLinks('/meetings/new',
          {'clientId': clientId, 'propertyId': links.propertyId}));
    case QuickAddAction.task:
      await showTaskSheet(context, client: links.client, deal: links.deal);
      onDone?.call();
    case QuickAddAction.logContact:
      await _logContact(context, links.client);
      onDone?.call();
  }
}

Future<void> _logContact(BuildContext context, PickerItem? linked) async {
  final l10n = AppLocalizations.of(context);
  var client = linked;
  if (client == null) {
    List<PickerItem> items;
    try {
      final all = await Injector.clientsRepository.getClients();
      items = [
        for (final c in all)
          PickerItem(id: c.id, title: c.fullName, subtitle: c.phone ?? c.email),
      ];
    } catch (_) {
      items = const [];
    }
    if (!context.mounted) return;
    client = await showEntityPicker(
      context,
      title: l10n.quickAddPickClient,
      items: items,
      searchHint: l10n.quickAddSearchClients,
      emptyLabel: l10n.quickAddNoClients,
    );
  }
  if (client == null || !context.mounted) return;
  final id = client.id;
  final saved = await showLogContactSheet(
    context,
    subtitle: client.title.isEmpty ? null : l10n.quickAddFor(client.title),
    onSave: (type, note, occurredAt) async {
      await Injector.clientsRepository
          .logActivity(id, type: type, note: note, occurredAt: occurredAt);
    },
  );
  if (!saved || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(l10n.clientsActivityLogged,
            maxLines: 2, overflow: TextOverflow.ellipsis)));
}
