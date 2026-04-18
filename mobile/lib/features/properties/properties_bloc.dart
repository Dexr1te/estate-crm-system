import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';

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

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState> {
  final ApiService _api;
  PropertiesBloc(this._api) : super(PropertiesInitial()) {
    on<PropertiesLoadEvent>(_onLoad);
    on<PropertiesDeleteEvent>(_onDelete);
    on<PropertiesCreateEvent>(_onCreate);
    on<PropertiesUpdateEvent>(_onUpdate);
    on<PropertiesUpdateStatusEvent>(_onUpdateStatus);
  }
  Future<void> _onLoad(
      PropertiesLoadEvent e, Emitter<PropertiesState> emit) async {
    emit(PropertiesLoading());
    try {
      emit(PropertiesLoaded(await _api.getProperties(
          status: e.status, type: e.type, search: e.search)));
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onDelete(
      PropertiesDeleteEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _api.deleteProperty(e.id);
      emit(PropertiesActionSuccess('Property deleted'));
      add(PropertiesLoadEvent());
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onCreate(
      PropertiesCreateEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _api.createProperty(e.data);
      emit(PropertiesActionSuccess('Property created'));
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onUpdate(
      PropertiesUpdateEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _api.updateProperty(e.id, e.data);
      emit(PropertiesActionSuccess('Property updated'));
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onUpdateStatus(
      PropertiesUpdateStatusEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _api.updatePropertyStatus(e.id, e.status);
      emit(PropertiesActionSuccess('Status updated'));
      add(PropertiesLoadEvent());
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }
}
