import 'package:real_estate_crm/core/models/models.dart';

abstract class PropertiesEvent {}

class PropertiesLoadEvent extends PropertiesEvent {
  final PropertyStatus? status;
  final PropertyType? type;
  final String? search;
  PropertiesLoadEvent({this.status, this.type, this.search});
}

class PropertiesDeleteEvent extends PropertiesEvent {
  final int id;
  PropertiesDeleteEvent(this.id);
}

class PropertiesCreateEvent extends PropertiesEvent {
  final Map<String, dynamic> data;
  PropertiesCreateEvent(this.data);
}

class PropertiesUpdateEvent extends PropertiesEvent {
  final int id;
  final Map<String, dynamic> data;
  PropertiesUpdateEvent(this.id, this.data);
}

class PropertiesUpdateStatusEvent extends PropertiesEvent {
  final int id;
  final PropertyStatus status;
  PropertiesUpdateStatusEvent(this.id, this.status);
}