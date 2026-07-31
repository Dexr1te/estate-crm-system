import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class PropertiesState {}

class PropertiesInitial extends PropertiesState {}

class PropertiesLoading extends PropertiesState {}

class PropertiesLoaded extends PropertiesState {
  final List<PropertyResponse> properties;

  final bool hasMore;

  final bool isLoadingMore;

  PropertiesLoaded(
    this.properties, {
    this.hasMore = false,
    this.isLoadingMore = false,
  });
}

class PropertiesError extends PropertiesState {
  final String message;
  PropertiesError(this.message);
}

class PropertiesActionSuccess extends PropertiesLoaded
    implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  PropertiesActionSuccess(this.message, super.properties, {super.hasMore});
}

class PropertiesActionFailure extends PropertiesLoaded
    implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  PropertiesActionFailure(this.message, super.properties, {super.hasMore});
}

class PropertyCreated extends PropertiesLoaded {
  final PropertyResponse property;
  PropertyCreated(this.property, super.properties, {super.hasMore});
}
