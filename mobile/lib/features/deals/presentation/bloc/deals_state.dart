import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class DealsState {}

class DealsInitial extends DealsState {}

class DealsLoading extends DealsState {}

class DealsLoaded extends DealsState {
  final List<DealResponse> deals;
  DealsLoaded(this.deals);
}

class DealsError extends DealsState {
  final ApiFailure failure;
  DealsError(this.failure);
}

class DealsActionSuccess extends DealsLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  DealsActionSuccess(this.message, super.deals);
}

class DealsActionFailure extends DealsLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  DealsActionFailure(this.failure, super.deals);
}
