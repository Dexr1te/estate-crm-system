import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class DealsState {}

class DealsInitial extends DealsState {}

class DealsLoading extends DealsState {}

class DealsLoaded extends DealsState {
  final List<DealResponse> deals;
  DealsLoaded(this.deals);
}

/// The *load* failed and there is nothing to show — the screen renders a
/// full-page error. A failed write uses [DealsActionFailure] instead.
class DealsError extends DealsState {
  final String message;
  DealsError(this.message);
}

/// A write succeeded. Extends [DealsLoaded] and carries the list forward so
/// the screen keeps its content (and its stage counts) while the reload runs.
class DealsActionSuccess extends DealsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  DealsActionSuccess(this.message, super.deals);
}

/// A write failed, but what is already loaded is still valid: show the message
/// and keep the list rather than replacing the screen with an error page.
class DealsActionFailure extends DealsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  DealsActionFailure(this.message, super.deals);
}