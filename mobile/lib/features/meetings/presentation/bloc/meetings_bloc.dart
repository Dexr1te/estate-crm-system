import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState>
    with LoadGeneration {
  final MeetingsRepository _repo;
  MeetingsBloc(this._repo) : super(MeetingsInitial()) {
    on<MeetingsLoadEvent>(_onLoad);
    on<MeetingsResetEvent>(_onReset);
    on<MeetingsDeleteEvent>(_onDelete);
    on<MeetingsCreateEvent>(_onCreate);
    on<MeetingsUpdateEvent>(_onUpdate);
    on<MeetingsCompleteEvent>(_onComplete);
  }

  List<MeetingResponse> get _current {
    final s = state;
    return s is MeetingsLoaded ? s.meetings : const [];
  }

  MeetingsState _failure(Object err) => _current.isEmpty
      ? MeetingsError(apiErrorMessage(err))
      : MeetingsActionFailure(apiErrorMessage(err), _current);

  void _onReset(MeetingsResetEvent e, Emitter<MeetingsState> emit) {
    startLoad();
    emit(MeetingsInitial());
  }

  Future<void> _onLoad(MeetingsLoadEvent e, Emitter<MeetingsState> emit) async {
    final ticket = startLoad();
    if (_current.isEmpty) emit(MeetingsLoading());
    try {
      final meetings = await _repo.getMeetings();
      if (isStale(ticket)) return;
      emit(MeetingsLoaded(meetings));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(MeetingsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onDelete(
      MeetingsDeleteEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.deleteMeeting(e.id);
      emit(MeetingsActionSuccess('Meeting deleted', _current));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onCreate(
      MeetingsCreateEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.createMeeting(e.data);
      emit(MeetingsActionSuccess('Meeting created', _current));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdate(
      MeetingsUpdateEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.updateMeeting(e.id, e.data);
      emit(MeetingsActionSuccess('Meeting updated', _current));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onComplete(
      MeetingsCompleteEvent e, Emitter<MeetingsState> emit) async {
    try {
      await _repo.completeMeeting(e.id);
      emit(MeetingsActionSuccess('Meeting completed', _current));
      add(MeetingsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }
}
