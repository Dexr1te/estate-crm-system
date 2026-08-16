import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

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
  final ApiFailure failure;
  PropertiesError(this.failure);
}

class PropertiesActionSuccess extends PropertiesLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  PropertiesActionSuccess(this.message, super.properties, {super.hasMore});
}

class PropertiesActionFailure extends PropertiesLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  PropertiesActionFailure(this.failure, super.properties, {super.hasMore});
}

class PropertyCreated extends PropertiesLoaded {
  final PropertyResponse property;
  PropertyCreated(this.property, super.properties, {super.hasMore});
}
