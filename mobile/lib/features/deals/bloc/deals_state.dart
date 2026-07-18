import 'package:real_estate_crm/core/models/models.dart';

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

class DealsActionSuccess extends DealsState {
  final String message;
  DealsActionSuccess(this.message);
}