import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RemindersEvent {}

class RemindersLoadEvent extends RemindersEvent {}

class RemindersLeadChangedEvent extends RemindersEvent {
  final ReminderLead? lead;
  RemindersLeadChangedEvent(this.lead);
}

class RemindersState {
  final ReminderSettings settings;

  final bool permissionDenied;

  const RemindersState(this.settings, {this.permissionDenied = false});
}

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

      await _gateway.cancelAll();
      emit(RemindersState(
          ReminderSettings(enabled: false, lead: state.settings.lead)));
      return;
    }

    final granted = await _gateway.requestPermission();
    if (!granted) {
      await prefs.setBool(_enabledKey, false);
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
