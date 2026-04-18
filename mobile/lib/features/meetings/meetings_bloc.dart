import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';

abstract class MeetingsEvent {}

class MeetingsLoadEvent extends MeetingsEvent {}

class MeetingsDeleteEvent extends MeetingsEvent {
  final int id;
  MeetingsDeleteEvent(this.id);
}

class MeetingsCreateEvent extends MeetingsEvent {
  final Map<String, dynamic> data;
  MeetingsCreateEvent(this.data);
}

class MeetingsUpdateEvent extends MeetingsEvent {
  final int id;
  final Map<String, dynamic> data;
  MeetingsUpdateEvent(this.id, this.data);
}

class MeetingsCompleteEvent extends MeetingsEvent {
  final int id;
  MeetingsCompleteEvent(this.id);
}

abstract class MeetingsState {}

class MeetingsInitial extends MeetingsState {}

class MeetingsLoading extends MeetingsState {}

class MeetingsLoaded extends MeetingsState {
  final List<MeetingResponse> meetings;
  MeetingsLoaded(this.meetings);
}

class MeetingsError extends MeetingsState {
  final String message;
  MeetingsError(this.message);
}

class MeetingsActionSuccess extends MeetingsState {
  final String message;
  MeetingsActionSuccess(this.message);
}

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  final ApiService _api;
  MeetingsBloc(this._api) : super(MeetingsInitial()) {
    on<MeetingsLoadEvent>(_onLoad);
    on<MeetingsDeleteEvent>(_onDelete);
    on<MeetingsCreateEvent>(_onCreate);
    on<MeetingsUpdateEvent>(_onUpdate);
    on<MeetingsCompleteEvent>(_onComplete);
  }
  Future<void> _onLoad(MeetingsLoadEvent e, Emitter<MeetingsState> emit) async {
    emit(MeetingsLoading());
    try {
      emit(MeetingsLoaded(await _api.getMeetings()));
    } catch (err) {
      emit(MeetingsError(err.toString()));
    }
  }

  Future<void> _onDelete(
      MeetingsDeleteEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _api.deleteMeeting(e.id);
      emit(MeetingsActionSuccess('Meeting deleted'));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(MeetingsError(err.toString()));
    }
  }

  Future<void> _onCreate(
      MeetingsCreateEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _api.createMeeting(e.data);
      emit(MeetingsActionSuccess('Meeting created'));
    } catch (err) {
      emit(MeetingsError(err.toString()));
    }
  }

  Future<void> _onUpdate(
      MeetingsUpdateEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _api.updateMeeting(e.id, e.data);
      emit(MeetingsActionSuccess('Meeting updated'));
    } catch (err) {
      emit(MeetingsError(err.toString()));
    }
  }

  Future<void> _onComplete(
      MeetingsCompleteEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _api.completeMeeting(e.id);
      emit(MeetingsActionSuccess('Meeting completed'));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(MeetingsError(err.toString()));
    }
  }
}
