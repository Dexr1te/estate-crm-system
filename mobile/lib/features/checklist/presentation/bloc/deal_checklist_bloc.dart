import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/deal_checklist_event.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/deal_checklist_state.dart';

class DealChecklistBloc extends Bloc<DealChecklistEvent, DealChecklistState> {
  final ChecklistRepository _repo;
  final int dealId;

  /// Who is ticking lines here, so a tick shows their name before the server
  /// has answered.
  final int? userId;
  final String userName;

  DealChecklistBloc(
    this._repo, {
    required this.dealId,
    this.userId,
    this.userName = '',
  }) : super(const DealChecklistState()) {
    on<DealChecklistLoadEvent>(_onLoad);
    on<DealChecklistToggleEvent>(_onToggle);
    on<DealChecklistAttachEvent>(_onAttach);
    on<DealChecklistAddEvent>(_onAdd);
    on<DealChecklistDeleteEvent>(_onDelete);
  }

  Future<void> _onLoad(
      DealChecklistLoadEvent e, Emitter<DealChecklistState> emit) async {
    if (state.status != DealChecklistStatus.loaded) {
      emit(state.copyWith(status: DealChecklistStatus.loading));
    }
    try {
      final items = await _repo.getDealChecklist(dealId);
      emit(state.copyWith(status: DealChecklistStatus.loaded, items: items));
    } catch (error) {
      final failure = ApiFailure.from(error);
      emit(state.status == DealChecklistStatus.loaded
          ? state.copyWith(outcome: DealChecklistWriteFailed(failure))
          : state.copyWith(
              status: DealChecklistStatus.error, loadFailure: failure));
    }
  }

  Future<void> _onToggle(
      DealChecklistToggleEvent e, Emitter<DealChecklistState> emit) async {
    final item = e.item;
    if (state.busyIds.contains(item.id)) return;
    final done = !item.done;
    final optimistic = item.copyWith(
      done: done,
      doneAt: done ? AppClock.now() : null,
      doneById: done ? userId : null,
      doneByName: done ? userName : null,
    );
    await _write(emit, item, optimistic,
        () => _repo.updateItem(dealId, item.id, done: done));
  }

  Future<void> _onAttach(
      DealChecklistAttachEvent e, Emitter<DealChecklistState> emit) async {
    final item = e.item;
    if (state.busyIds.contains(item.id)) return;
    await _write(
        emit,
        item,
        item,
        () => _repo.updateItem(dealId, item.id,
            documentId: e.documentId, detachDocument: e.documentId == null));
  }

  Future<void> _write(
    Emitter<DealChecklistState> emit,
    ChecklistItem before,
    ChecklistItem shown,
    Future<ChecklistItem> Function() call,
  ) async {
    emit(state.copyWith(
      items: _replace(state.items, shown),
      busyIds: {...state.busyIds, before.id},
    ));
    try {
      final saved = await call();
      emit(state.copyWith(
        items: _replace(state.items, saved),
        busyIds: {...state.busyIds}..remove(before.id),
      ));
    } catch (error) {
      emit(state.copyWith(
        items: _replace(state.items, before),
        busyIds: {...state.busyIds}..remove(before.id),
        outcome: DealChecklistWriteFailed(ApiFailure.from(error)),
      ));
    }
  }

  Future<void> _onAdd(
      DealChecklistAddEvent e, Emitter<DealChecklistState> emit) async {
    final title = e.title.trim();
    if (title.isEmpty || state.adding) return;
    emit(state.copyWith(adding: true));
    try {
      final saved = await _repo.addItem(dealId,
          stage: e.stage, title: title, required: e.required);
      final items = [...state.items, saved]..sort(_order);
      emit(state.copyWith(items: items, adding: false));
    } catch (error) {
      emit(state.copyWith(
          adding: false,
          outcome: DealChecklistWriteFailed(ApiFailure.from(error))));
    }
  }

  Future<void> _onDelete(
      DealChecklistDeleteEvent e, Emitter<DealChecklistState> emit) async {
    final before = state.items;
    emit(
        state.copyWith(items: before.where((i) => i.id != e.item.id).toList()));
    try {
      await _repo.deleteItem(dealId, e.item.id);
    } catch (error) {
      emit(state.copyWith(
          items: before,
          outcome: DealChecklistWriteFailed(ApiFailure.from(error))));
    }
  }

  static List<ChecklistItem> _replace(
          List<ChecklistItem> items, ChecklistItem next) =>
      [for (final i in items) i.id == next.id ? next : i];

  static int _order(ChecklistItem a, ChecklistItem b) {
    final byStage = a.stage.index.compareTo(b.stage.index);
    return byStage != 0 ? byStage : a.position.compareTo(b.position);
  }
}
