import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

abstract class DocumentsState {}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentResponse> documents;

  final bool uploading;

  final Set<int> busyIds;

  DocumentsLoaded(
    this.documents, {
    this.uploading = false,
    this.busyIds = const {},
  });
}

class DocumentsError extends DocumentsState {
  final ApiFailure failure;
  DocumentsError(this.failure);
}

class DocumentsActionSuccess extends DocumentsLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  DocumentsActionSuccess(this.message, super.documents);
}

class DocumentsActionFailure extends DocumentsLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  DocumentsActionFailure(this.failure, super.documents);
}

class DocumentsProblemReported extends DocumentsLoaded
    implements ActionOutcome {
  final LocalProblem problem;

  DocumentsProblemReported(this.problem, super.documents);

  @override
  String text(AppLocalizations l10n) => localProblemLabel(l10n, problem);

  @override
  bool get isFailure => true;
}
