import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  final MeetingsRepository _repo;
  MeetingsBloc(this._repo) : super(MeetingsInitial()) {
    on<MeetingsLoadEvent>(_onLoad);
    on<MeetingsDeleteEvent>(_onDelete);
    on<MeetingsCreateEvent>(_onCreate);
    on<MeetingsUpdateEvent>(_onUpdate);
    on<MeetingsCompleteEvent>(_onComplete);
  }
  Future<void> _onLoad(MeetingsLoadEvent e, Emitter<MeetingsState> emit) async {
    emit(MeetingsLoading());
    try {
      emit(MeetingsLoaded(await _repo.getMeetings()));
    } catch (err) {
      emit(MeetingsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onDelete(
      MeetingsDeleteEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.deleteMeeting(e.id);
      emit(MeetingsActionSuccess('Meeting deleted'));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(MeetingsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onCreate(
      MeetingsCreateEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.createMeeting(e.data);
      emit(MeetingsActionSuccess('Meeting created'));
    } catch (err) {
      emit(MeetingsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onUpdate(
      MeetingsUpdateEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.updateMeeting(e.id, e.data);
      emit(MeetingsActionSuccess('Meeting updated'));
    } catch (err) {
      emit(MeetingsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onComplete(
      MeetingsCompleteEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.completeMeeting(e.id);
      emit(MeetingsActionSuccess('Meeting completed'));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(MeetingsError(apiErrorMessage(err)));
    }
  }
}
