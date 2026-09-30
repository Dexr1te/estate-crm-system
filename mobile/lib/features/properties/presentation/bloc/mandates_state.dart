import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

abstract class MandatesState {
  const MandatesState();
}

class MandatesInitial extends MandatesState {
  const MandatesInitial();
}

class MandatesLoading extends MandatesState {
  const MandatesLoading();
}

/// Soonest (or longest gone) first, as the server sends them.
class MandatesLoaded extends MandatesState {
  final List<PropertyResponse> properties;
  const MandatesLoaded(this.properties);
}

class MandatesError extends MandatesState {
  final ApiFailure failure;
  const MandatesError(this.failure);
}
