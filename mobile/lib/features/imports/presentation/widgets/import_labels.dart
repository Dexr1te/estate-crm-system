import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The name a person sees for a field key the server sends. `type` is a
/// client's kind on a client sheet and the kind of listing on a listing sheet.
String importFieldLabel(AppLocalizations l10n, ImportKind kind, String field) =>
    switch (field) {
      'fullName' => l10n.importFieldFullName,
      'phone' => l10n.importFieldPhone,
      'email' => l10n.importFieldEmail,
      'type' => kind == ImportKind.clients
          ? l10n.importFieldClientType
          : l10n.importFieldPropertyType,
      'notes' => l10n.importFieldNotes,
      'wantedCity' => l10n.importFieldWantedCity,
      'wantedType' => l10n.importFieldWantedType,
      'budgetMin' => l10n.importFieldBudgetMin,
      'budgetMax' => l10n.importFieldBudgetMax,
      'minRooms' => l10n.importFieldMinRooms,
      'minAreaSqm' => l10n.importFieldMinArea,
      'tags' => l10n.importFieldTags,
      'title' => l10n.importFieldTitle,
      'address' => l10n.importFieldAddress,
      'city' => l10n.importFieldCity,
      'status' => l10n.importFieldStatus,
      'price' => l10n.importFieldPrice,
      'areaSqm' => l10n.importFieldArea,
      'rooms' => l10n.importFieldRooms,
      'floor' => l10n.importFieldFloor,
      'totalFloors' => l10n.importFieldTotalFloors,
      'description' => l10n.importFieldDescription,
      _ => field,
    };

String importErrorLabel(AppLocalizations l10n, String code) => switch (code) {
      'REQUIRED' => l10n.importErrorRequired,
      'INVALID_NUMBER' => l10n.importErrorInvalidNumber,
      'INVALID_EMAIL' => l10n.importErrorInvalidEmail,
      'INVALID_PHONE' => l10n.importErrorInvalidPhone,
      'UNKNOWN_VALUE' => l10n.importErrorUnknownValue,
      'TOO_LONG' => l10n.importErrorTooLong,
      'NEGATIVE' => l10n.importErrorNegative,
      _ => l10n.importErrorOutOfRange,
    };

/// What went wrong with the file itself, in words; the server's codes first.
String importFailureLabel(AppLocalizations l10n, ImportState state) {
  switch (state.fileProblem) {
    case ImportFileProblem.tooLarge:
      return l10n.importFileTooLarge;
    case ImportFileProblem.notCsv:
      return l10n.importNotCsv;
    case null:
      break;
  }
  final failure = state.failure ?? const ApiFailure(ApiFailureKind.unknown);
  return switch (failure.serverCode) {
    'IMPORT_FILE_TOO_LARGE' => l10n.importFileTooLarge,
    'IMPORT_TOO_MANY_ROWS' => l10n.importTooManyRows,
    'IMPORT_EMPTY_FILE' => l10n.importEmptyFile,
    _ => apiFailureLabel(l10n, failure),
  };
}
