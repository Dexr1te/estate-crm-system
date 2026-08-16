import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RemindersEvent {}

class RemindersLoadEvent extends RemindersEvent {}

/// Picking a lead time turns reminders on; picking null turns them off.
class RemindersLeadChangedEvent extends RemindersEvent {
  final ReminderLead? lead;
  RemindersLeadChangedEvent(this.lead);
}

class RemindersState {
  final ReminderSettings settings;

  /// Set when the OS was asked and said no, so the screen can explain why the
  /// switch bounced back instead of appearing to ignore the tap.
  final bool permissionDenied;

  const RemindersState(this.settings, {this.permissionDenied = false});
}

/// Whether the app warns you before a meeting, and how far ahead.
///
/// Permission is asked for here rather than at launch: the prompt then arrives
/// attached to the thing that explains it, and an install that never wants
/// reminders is never interrupted.
class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  static const _enabledKey = 'reminders_enabled';
  static const _leadKey = 'reminders_lead';

  final NotificationGateway _gateway;

  RemindersBloc(this._gateway)
      : super(const RemindersState(ReminderSettings())) {
    on<RemindersLoadEvent>(_onLoad);
    on<RemindersLeadChangedEvent>(_onLeadChanged);
  }

  Future<void> _onLoad(
      RemindersLoadEvent e, Emitter<RemindersState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    final lead = _leadFromName(prefs.getString(_leadKey));
    emit(RemindersState(ReminderSettings(enabled: enabled, lead: lead)));
  }

  Future<void> _onLeadChanged(
      RemindersLeadChangedEvent e, Emitter<RemindersState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    if (e.lead == null) {
      await prefs.setBool(_enabledKey, false);
      // Nothing pending should outlive the setting that asked for it.
      await _gateway.cancelAll();
      emit(RemindersState(
          ReminderSettings(enabled: false, lead: state.settings.lead)));
      return;
    }

    // Asking every time the lead changes would be noise; the OS only prompts
    // once anyway and answers from memory after that.
    final granted = await _gateway.requestPermission();
    if (!granted) {
      emit(RemindersState(
        ReminderSettings(enabled: false, lead: state.settings.lead),
        permissionDenied: true,
      ));
      return;
    }

    await prefs.setBool(_enabledKey, true);
    await prefs.setString(_leadKey, e.lead!.name);
    emit(RemindersState(ReminderSettings(enabled: true, lead: e.lead!)));
  }

  static ReminderLead _leadFromName(String? name) => ReminderLead.values
      .firstWhere((l) => l.name == name, orElse: () => ReminderLead.oneHour);
}
