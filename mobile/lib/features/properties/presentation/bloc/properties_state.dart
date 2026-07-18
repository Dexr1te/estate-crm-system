import 'package:real_estate_crm/core/models/models.dart';

abstract class PropertiesState {}

class PropertiesInitial extends PropertiesState {}

class PropertiesLoading extends PropertiesState {}

class PropertiesLoaded extends PropertiesState {
  final List<PropertyResponse> properties;
  PropertiesLoaded(this.properties);
}

class PropertiesError extends PropertiesState {
  final String message;
  PropertiesError(this.message);
}

class PropertiesActionSuccess extends PropertiesState {
  final String message;
  PropertiesActionSuccess(this.message);
}

// NEW: emitted after a successful create, carries the new property's id
class PropertyCreated extends PropertiesState {
  final PropertyResponse property;
  PropertyCreated(this.property);
}