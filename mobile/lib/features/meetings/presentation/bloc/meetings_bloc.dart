import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState>
    with SingleFlight, CollectionBloc<MeetingsEvent, MeetingsState> {
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

  MeetingsState _failure(String message) => _current.isEmpty
      ? MeetingsError(message)
      : MeetingsActionFailure(message, _current);

  void _onReset(MeetingsResetEvent e, Emitter<MeetingsState> emit) {
    invalidate();
    emit(MeetingsInitial());
  }

  Future<void> _onLoad(MeetingsLoadEvent e, Emitter<MeetingsState> emit) =>
      load(
        emit,
        keepVisible: _current.isNotEmpty,
        skeleton: MeetingsLoading(),
        fetch: _repo.getMeetings,
        onData: MeetingsLoaded.new,
        onFailure: MeetingsError.new,
      );

  Future<void> _act(Emitter<MeetingsState> emit, String key, String success,
          Future<void> Function() action) =>
      write(
        emit,
        key: key,
        perform: action,
        onSuccess: (_) => MeetingsActionSuccess(success, _current),
        onFailure: _failure,
        reload: () => add(MeetingsLoadEvent()),
      );

  Future<void> _onDelete(MeetingsDeleteEvent e, Emitter<MeetingsState> emit) =>
      _act(emit, 'delete-${e.id}', 'Meeting deleted',
          () => _repo.deleteMeeting(e.id));

  Future<void> _onCreate(MeetingsCreateEvent e, Emitter<MeetingsState> emit) =>
      _act(emit, 'create-${e.data['clientId']}-${e.data['scheduledAt']}',
          'Meeting created', () => _repo.createMeeting(e.data));

  Future<void> _onUpdate(MeetingsUpdateEvent e, Emitter<MeetingsState> emit) =>
      _act(emit, 'update-${e.id}', 'Meeting updated',
          () => _repo.updateMeeting(e.id, e.data));

  Future<void> _onComplete(
          MeetingsCompleteEvent e, Emitter<MeetingsState> emit) =>
      _act(emit, 'complete-${e.id}', 'Meeting completed',
          () => _repo.completeMeeting(e.id));
}
