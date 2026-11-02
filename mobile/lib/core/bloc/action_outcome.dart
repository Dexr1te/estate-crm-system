import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/feedback/app_haptics.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

abstract mixin class ActionOutcome {
  String text(AppLocalizations l10n);

  bool get isFailure;
}

mixin ActionSucceeded implements ActionOutcome {
  ActionMessage get message;

  @override
  String text(AppLocalizations l10n) => actionMessageLabel(l10n, message);

  @override
  bool get isFailure => false;
}

mixin ActionFailed implements ActionOutcome {
  ApiFailure get failure;

  @override
  String text(AppLocalizations l10n) => apiFailureLabel(l10n, failure);

  @override
  bool get isFailure => true;
}

void showActionOutcome(BuildContext context, Object? state) {
  if (state is! ActionOutcome || !context.mounted) return;
  if (state.isFailure) {
    AppHaptics.warning();
  } else {
    AppHaptics.success();
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(state.text(AppLocalizations.of(context))),
      backgroundColor: state.isFailure ? context.tokens.dangerSolid : null,
    ));
}

/// A write from a record's own screen that failed while its list had never
/// loaded. The bloc reports that as the list's load error, which only the list
/// screen draws -- and a record opened from a push, a client card or the
/// dashboard has no list screen underneath to draw it. The record's screen
/// says it instead.
void showWriteFailure(BuildContext context, ApiFailure failure) =>
    showActionOutcome(context, _WriteFailed(failure));

class _WriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  _WriteFailed(this.failure);
}
