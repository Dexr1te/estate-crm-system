import 'package:real_estate_crm/core/models/models.dart';

/// One line of the agency template while the manager is editing it: no id
/// yet, and a [key] that survives reordering.
class TemplateLine {
  final String key;
  final ChecklistStage stage;
  final String title;
  final bool required;

  const TemplateLine({
    required this.key,
    required this.stage,
    required this.title,
    this.required = false,
  });

  TemplateLine copyWith({String? title, bool? required}) => TemplateLine(
        key: key,
        stage: stage,
        title: title ?? this.title,
        required: required ?? this.required,
      );

  Map<String, dynamic> toJson() =>
      {'stage': stage.name, 'title': title.trim(), 'required': required};
}

/// The furthest checklist stage a deal in [status] has reached. A lost deal
/// counts as having got as far as negotiation, as on the server.
ChecklistStage checklistStageOf(DealStatus status) {
  switch (status) {
    case DealStatus.LEAD:
      return ChecklistStage.LEAD;
    case DealStatus.NEGOTIATION:
    case DealStatus.CLOSED_LOST:
      return ChecklistStage.NEGOTIATION;
    case DealStatus.CLOSED_WON:
      return ChecklistStage.CLOSED_WON;
  }
}

/// The stages whose required lines a move to [target] leaves behind: those
/// before it. Moving back, or to lost, leaves nothing behind.
List<ChecklistStage> stagesBehind(DealStatus from, DealStatus target) {
  if (target != DealStatus.NEGOTIATION && target != DealStatus.CLOSED_WON) {
    return const [];
  }
  final to = checklistStageOf(target);
  if (from != DealStatus.CLOSED_LOST &&
      checklistStageOf(from).index >= to.index) {
    return const [];
  }
  return ChecklistStage.values.where((s) => s.index < to.index).toList();
}

/// How many required lines are still open behind a move of [deal] to
/// [target], from the counts the deal list carries.
int openRequiredForMove(DealResponse deal, DealStatus target) =>
    stagesBehind(deal.status, target)
        .fold(0, (sum, s) => sum + (deal.openRequiredByStage[s.name] ?? 0));

/// The same, from a loaded checklist — fresher than the deal's counts once
/// somebody has been ticking lines on the detail screen.
int openRequiredInItems(
    List<ChecklistItem> items, DealStatus from, DealStatus target) {
  final behind = stagesBehind(from, target).toSet();
  return items
      .where((i) => i.required && !i.done && behind.contains(i.stage))
      .length;
}
