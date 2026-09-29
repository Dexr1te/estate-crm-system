import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';

enum ChecklistTemplateStatus { loading, loaded, error }

class ChecklistTemplateState {
  final ChecklistTemplateStatus status;

  /// Every line, grouped by stage in stage order; within a stage, the order
  /// new deals will get them in.
  final List<TemplateLine> lines;

  /// Edited since the last load or save.
  final bool dirty;
  final bool saving;
  final ApiFailure? loadFailure;
  final ActionOutcome? outcome;

  const ChecklistTemplateState({
    this.status = ChecklistTemplateStatus.loading,
    this.lines = const [],
    this.dirty = false,
    this.saving = false,
    this.loadFailure,
    this.outcome,
  });

  List<TemplateLine> linesOf(ChecklistStage stage) =>
      lines.where((l) => l.stage == stage).toList();

  ChecklistTemplateState copyWith({
    ChecklistTemplateStatus? status,
    List<TemplateLine>? lines,
    bool? dirty,
    bool? saving,
    ApiFailure? loadFailure,
    ActionOutcome? outcome,
  }) =>
      ChecklistTemplateState(
        status: status ?? this.status,
        lines: lines ?? this.lines,
        dirty: dirty ?? this.dirty,
        saving: saving ?? this.saving,
        loadFailure: loadFailure,
        outcome: outcome,
      );
}

class ChecklistTemplateSaved with ActionSucceeded {
  @override
  ActionMessage get message => ActionMessage.checklistSaved;
}

class ChecklistTemplateSaveFailed with ActionFailed {
  @override
  final ApiFailure failure;
  ChecklistTemplateSaveFailed(this.failure);
}
