import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

/// The one-shot result of a write, carried by a state that still holds the
/// data the write did not invalidate.
///
/// Feature states implement this so a screen handles success and failure in
/// one branch — the failure case is easy to forget when each feature spells it
/// differently, and a swallowed failure looks to the user like a silent no-op.
///
/// A failed *load* is not an outcome: it leaves nothing to show, so it stays a
/// distinct `…Error` state that the screen renders as a full page.
abstract mixin class ActionOutcome {
  String get message;

  /// Tints the snackbar and separates "saved" from "couldn't save".
  bool get isFailure;
}

/// Surfaces an [ActionOutcome] as a snackbar, red when it failed.
///
/// Takes any state and ignores the ones that aren't outcomes, so a listener
/// can hand its state straight over without a type test of its own — the point
/// is that neither half of the pair can be left unhandled.
void showActionOutcome(BuildContext context, Object? state) {
  if (state is! ActionOutcome || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(state.message),
      backgroundColor: state.isFailure ? context.tokens.dangerSolid : null,
    ));
}
