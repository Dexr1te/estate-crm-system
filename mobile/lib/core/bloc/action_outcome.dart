import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

abstract mixin class ActionOutcome {
  String get message;

  bool get isFailure;
}

void showActionOutcome(BuildContext context, Object? state) {
  if (state is! ActionOutcome || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(state.message),
      backgroundColor: state.isFailure ? context.tokens.dangerSolid : null,
    ));
}
