import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/checklist_template_event.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/checklist_template_state.dart';

/// The manager's copy of the agency template while it is being edited.
/// Nothing reaches the server until [ChecklistTemplateSaveEvent].
class ChecklistTemplateBloc
    extends Bloc<ChecklistTemplateEvent, ChecklistTemplateState> {
  final ChecklistRepository _repo;
  int _nextKey = 0;

  ChecklistTemplateBloc(this._repo) : super(const ChecklistTemplateState()) {
    on<ChecklistTemplateLoadEvent>(_onLoad);
    on<ChecklistTemplateAddEvent>(_onAdd);
    on<ChecklistTemplateEditEvent>(_onEdit);
    on<ChecklistTemplateDeleteEvent>(_onDelete);
    on<ChecklistTemplateReorderEvent>(_onReorder);
    on<ChecklistTemplateSaveEvent>(_onSave);
  }

  Future<void> _onLoad(ChecklistTemplateLoadEvent e,
      Emitter<ChecklistTemplateState> emit) async {
    emit(state.copyWith(status: ChecklistTemplateStatus.loading));
    try {
      final items = await _repo.getTemplate();
      emit(state.copyWith(
          status: ChecklistTemplateStatus.loaded,
          lines: _fromItems(items),
          dirty: false));
    } catch (error) {
      emit(state.copyWith(
          status: ChecklistTemplateStatus.error,
          loadFailure: ApiFailure.from(error)));
    }
  }

  void _onAdd(
      ChecklistTemplateAddEvent e, Emitter<ChecklistTemplateState> emit) {
    final title = e.title.trim();
    if (title.isEmpty) return;
    final line = TemplateLine(
        key: 'new-${_nextKey++}',
        stage: e.stage,
        title: title,
        required: e.required);
    _emitLines(emit, _grouped([...state.lines, line]));
  }

  void _onEdit(
      ChecklistTemplateEditEvent e, Emitter<ChecklistTemplateState> emit) {
    final title = e.title?.trim();
    _emitLines(emit, [
      for (final l in state.lines)
        l.key == e.key
            ? l.copyWith(
                title: title == null || title.isEmpty ? null : title,
                required: e.required)
            : l,
    ]);
  }

  void _onDelete(
      ChecklistTemplateDeleteEvent e, Emitter<ChecklistTemplateState> emit) {
    _emitLines(emit, state.lines.where((l) => l.key != e.key).toList());
  }

  void _onReorder(
      ChecklistTemplateReorderEvent e, Emitter<ChecklistTemplateState> emit) {
    final stage = [...state.linesOf(e.stage)];
    if (e.oldIndex < 0 || e.oldIndex >= stage.length) return;
    final moved = stage.removeAt(e.oldIndex);
    final to = e.newIndex > e.oldIndex ? e.newIndex - 1 : e.newIndex;
    stage.insert(to.clamp(0, stage.length), moved);
    _emitLines(emit, [
      for (final s in ChecklistStage.values)
        ...(s == e.stage ? stage : state.linesOf(s)),
    ]);
  }

  Future<void> _onSave(ChecklistTemplateSaveEvent e,
      Emitter<ChecklistTemplateState> emit) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final saved = await _repo.saveTemplate(state.lines);
      emit(state.copyWith(
          lines: _fromItems(saved),
          saving: false,
          dirty: false,
          outcome: ChecklistTemplateSaved()));
    } catch (error) {
      emit(state.copyWith(
          saving: false,
          outcome: ChecklistTemplateSaveFailed(ApiFailure.from(error))));
    }
  }

  void _emitLines(
          Emitter<ChecklistTemplateState> emit, List<TemplateLine> lines) =>
      emit(state.copyWith(lines: lines, dirty: true));

  List<TemplateLine> _fromItems(List<ChecklistItem> items) => _grouped([
        for (final i in items)
          TemplateLine(
              key: 'id-${i.id}',
              stage: i.stage,
              title: i.title,
              required: i.required),
      ]);

  static List<TemplateLine> _grouped(List<TemplateLine> lines) => [
        for (final s in ChecklistStage.values)
          ...lines.where((l) => l.stage == s),
      ];
}
