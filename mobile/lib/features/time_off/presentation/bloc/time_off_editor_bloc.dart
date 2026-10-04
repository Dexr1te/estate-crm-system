import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/time_off/domain/repositories/time_off_repository.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';

abstract class TimeOffEditorEvent {}

/// Reads the absence being changed.
class TimeOffEditorLoadEvent extends TimeOffEditorEvent {}

/// Writes it down, or saves the change.
class TimeOffEditorSaveEvent extends TimeOffEditorEvent {
  final TimeOffDraft draft;
  TimeOffEditorSaveEvent(this.draft);
}

/// Cancels the absence being changed.
class TimeOffEditorCancelEvent extends TimeOffEditorEvent {}

/// What the last write did.
enum TimeOffEditorOutcome { saved, cancelled, failed }

class TimeOffEditorState {
  /// The absence as the server last answered; null while a new one is not
  /// written down yet.
  final TimeOff? timeOff;
  final bool loading;
  final ApiFailure? loadFailure;
  final bool busy;
  final TimeOffEditorOutcome? outcome;
  final ApiFailure? failure;

  /// Bumped on every write, so the screen hears each one once.
  final int writes;

  const TimeOffEditorState({
    this.timeOff,
    this.loading = false,
    this.loadFailure,
    this.busy = false,
    this.outcome,
    this.failure,
    this.writes = 0,
  });
}

/// Writes down a new absence, or reads, changes and cancels an existing one.
class TimeOffEditorBloc extends Bloc<TimeOffEditorEvent, TimeOffEditorState>
    with SingleFlight {
  final TimeOffRepository _repo;

  /// The absence being changed; null for a new one.
  int? id;

  TimeOffEditorBloc(this._repo, {this.id})
      : super(TimeOffEditorState(loading: id != null)) {
    on<TimeOffEditorLoadEvent>(_load);
    on<TimeOffEditorSaveEvent>(_save);
    on<TimeOffEditorCancelEvent>(_cancel);
  }

  Future<void> _load(
      TimeOffEditorLoadEvent e, Emitter<TimeOffEditorState> emit) async {
    final current = id;
    if (current == null) return;
    emit(TimeOffEditorState(loading: true, writes: state.writes));
    try {
      final found = await _repo.getOne(current);
      emit(TimeOffEditorState(timeOff: found, writes: state.writes));
    } catch (err) {
      emit(TimeOffEditorState(
          loadFailure: ApiFailure.from(err), writes: state.writes));
    }
  }

  Future<void> _save(
          TimeOffEditorSaveEvent e, Emitter<TimeOffEditorState> emit) =>
      once('write', () async {
        emit(TimeOffEditorState(
            timeOff: state.timeOff, busy: true, writes: state.writes));
        try {
          final current = id;
          final saved = current == null
              ? await _repo.create(e.draft)
              : await _repo.update(current, e.draft);
          id = saved.id;
          emit(TimeOffEditorState(
              timeOff: saved,
              outcome: TimeOffEditorOutcome.saved,
              writes: state.writes + 1));
        } catch (err) {
          emit(TimeOffEditorState(
              timeOff: state.timeOff,
              outcome: TimeOffEditorOutcome.failed,
              failure: ApiFailure.from(err),
              writes: state.writes + 1));
        }
      });

  Future<void> _cancel(
          TimeOffEditorCancelEvent e, Emitter<TimeOffEditorState> emit) =>
      once('write', () async {
        final current = id;
        if (current == null) return;
        emit(TimeOffEditorState(
            timeOff: state.timeOff, busy: true, writes: state.writes));
        try {
          await _repo.cancel(current);
          emit(TimeOffEditorState(
              timeOff: state.timeOff,
              outcome: TimeOffEditorOutcome.cancelled,
              writes: state.writes + 1));
        } catch (err) {
          emit(TimeOffEditorState(
              timeOff: state.timeOff,
              outcome: TimeOffEditorOutcome.failed,
              failure: ApiFailure.from(err),
              writes: state.writes + 1));
        }
      });
}
