import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class PropertiesState {}

class PropertiesInitial extends PropertiesState {}

class PropertiesLoading extends PropertiesState {}

class PropertiesLoaded extends PropertiesState {
  final List<PropertyResponse> properties;

  /// Whether more pages are available to load.
  final bool hasMore;

  /// True while a "load more" page request is in flight (footer spinner).
  final bool isLoadingMore;

  PropertiesLoaded(
    this.properties, {
    this.hasMore = false,
    this.isLoadingMore = false,
  });
}

/// The *load* failed and there is nothing to show — the screen renders a
/// full-page error. A failed write uses [PropertiesActionFailure] instead.
class PropertiesError extends PropertiesState {
  final String message;
  PropertiesError(this.message);
}

/// A write succeeded. Extends [PropertiesLoaded] and carries the list forward
/// so the screen keeps its content while the reload runs — otherwise every
/// delete or status change blanks the list to a skeleton for a beat.
class PropertiesActionSuccess extends PropertiesLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  PropertiesActionSuccess(this.message, super.properties, {super.hasMore});
}

/// A write failed, but what is already loaded is still valid: show the message
/// and keep the list. Emitting [PropertiesError] here would throw away a
/// perfectly good screen because one status update was rejected.
class PropertiesActionFailure extends PropertiesLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  PropertiesActionFailure(this.message, super.properties, {super.hasMore});
}

// NEW: emitted after a successful create, carries the new property's id
class PropertyCreated extends PropertiesState {
  final PropertyResponse property;
  PropertyCreated(this.property);
}