import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState> {
  final PropertiesRepository _repo;
  PropertiesBloc(this._repo) : super(PropertiesInitial()) {
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
      emit(PropertiesLoaded(await _repo.getProperties(
          status: e.status, type: e.type, search: e.search)));
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onDelete(
      PropertiesDeleteEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.deleteProperty(e.id);
      emit(PropertiesActionSuccess('Property deleted'));
      add(PropertiesLoadEvent());
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onCreate(
      PropertiesCreateEvent e, Emitter<PropertiesState> emit) async {
    try {
      final created = await _repo.createProperty(e.data);
      emit(PropertyCreated(created)); // emit the full object with id
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onUpdate(
      PropertiesUpdateEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.updateProperty(e.id, e.data);
      emit(PropertiesActionSuccess('Property updated'));
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onUpdateStatus(
      PropertiesUpdateStatusEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.updatePropertyStatus(e.id, e.status);
      emit(PropertiesActionSuccess('Status updated'));
      add(PropertiesLoadEvent());
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }
}
