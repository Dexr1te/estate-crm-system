import 'package:flutter/material.dart';
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
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(state.text(AppLocalizations.of(context))),
      backgroundColor: state.isFailure ? context.tokens.dangerSolid : null,
    ));
}
