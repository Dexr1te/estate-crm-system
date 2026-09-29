import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/contact_follow_up.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/log_contact_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Tomorrow at ten, the time a "remind me" lands.
DateTime coldReminderDue(DateTime now) =>
    DateTime(now.year, now.month, now.day + 1, 10);

/// The quick actions on a client going cold, shared by the dashboard card and
/// the full list: call — and, back from the call, offer to log it — and
/// remind, with an undo.
mixin ColdClientActions<T extends StatefulWidget> on State<T> {
  ColdClientsBloc get coldBloc;

  late final ContactFollowUp _followUp = ContactFollowUp(onReturn: _offerToLog);

  @override
  void initState() {
    super.initState();
    _followUp.attach();
  }

  @override
  void dispose() {
    _followUp.detach();
    super.dispose();
  }

  Future<void> callCold(ColdClient client) async {
    final l10n = AppLocalizations.of(context);
    if (await ContactActions.call(client.phone)) {
      _followUp.begin(client.id, ActivityType.CALL);
    } else if (mounted) {
      showActionUnavailable(context, l10n.clientsNoPhone);
    }
  }

  void remindCold(ColdClient client) {
    final l10n = AppLocalizations.of(context);
    coldBloc.add(ColdClientsRemindEvent(
      client,
      title: l10n.clientsColdRemindTask(client.fullName),
      dueAt: coldReminderDue(AppClock.now()),
    ));
  }

  /// The listener for the cold list: a reminder names its time and can be
  /// taken back; a failure says why.
  void onColdState(BuildContext context, ColdClientsState state) {
    if (!context.mounted) return;
    if (state is ColdClientsReminderSet) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
              l10n.clientsColdReminderSet(formatTimeOfDay(state.dueAt)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          action: SnackBarAction(
            key: const ValueKey('cold-undo'),
            label: l10n.clientsColdUndo,
            onPressed: () =>
                coldBloc.add(ColdClientsUndoRemindEvent(state.taskId)),
          ),
        ));
    } else if (state is ActionOutcome) {
      showActionOutcome(context, state);
    }
  }

  Future<void> _offerToLog(PendingContact pending) async {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final l10n = AppLocalizations.of(context);
    final saved = await showLogContactSheet(
      context,
      onSave: (type, note, occurredAt) => Injector.clientsRepository
          .logActivity(pending.clientId,
              type: type, note: note, occurredAt: occurredAt),
      initialType: pending.type,
      initialOccurredAt: pending.startedAt,
      title: l10n.clientsFollowUpCall,
      subtitle: l10n.clientsFollowUpHint,
    );
    if (!saved || !mounted) return;
    coldBloc.add(ColdClientsLoadEvent());
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(l10n.clientsActivityLogged,
              maxLines: 2, overflow: TextOverflow.ellipsis)));
  }
}
