import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class DealsState {}

class DealsInitial extends DealsState {}

class DealsLoading extends DealsState {}

class DealsLoaded extends DealsState {
  final List<DealResponse> deals;
  DealsLoaded(this.deals);
}

class DealsError extends DealsState {
  final String message;
  DealsError(this.message);
}

class DealsActionSuccess extends DealsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  DealsActionSuccess(this.message, super.deals);
}

class DealsActionFailure extends DealsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  DealsActionFailure(this.message, super.deals);
}
