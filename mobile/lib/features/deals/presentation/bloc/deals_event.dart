import 'package:real_estate_crm/core/models/models.dart';

abstract class DealsEvent {}

class DealsLoadEvent extends DealsEvent {
  final DealStatus? status;
  DealsLoadEvent({this.status});
}

class DealsDeleteEvent extends DealsEvent {
  final int id;
  DealsDeleteEvent(this.id);
}

class DealsCreateEvent extends DealsEvent {
  final Map<String, dynamic> data;
  DealsCreateEvent(this.data);
}

class DealsUpdateEvent extends DealsEvent {
  final int id;
  final Map<String, dynamic> data;
  DealsUpdateEvent(this.id, this.data);
}

class DealsUpdateStatusEvent extends DealsEvent {
  final int id;
  final DealStatus status;
  DealsUpdateStatusEvent(this.id, this.status);
}