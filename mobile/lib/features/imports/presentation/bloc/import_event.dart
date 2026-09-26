import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';

abstract class ImportEvent {}

class ImportFileChosen extends ImportEvent {
  final ImportKind kind;
  final PickedFile file;
  ImportFileChosen(this.kind, this.file);
}

/// Column [column] now fills [field], or nothing when [field] is null.
class ImportColumnMapped extends ImportEvent {
  final int column;
  final String? field;
  ImportColumnMapped(this.column, this.field);
}

class ImportSkipDuplicatesChanged extends ImportEvent {
  final bool skip;
  ImportSkipDuplicatesChanged(this.skip);
}

class ImportAssigneeChanged extends ImportEvent {
  final AgentOption? agent;
  ImportAssigneeChanged(this.agent);
}

class ImportCommitRequested extends ImportEvent {}

class ImportRestarted extends ImportEvent {}
