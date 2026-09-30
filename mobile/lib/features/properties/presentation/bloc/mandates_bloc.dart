import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_state.dart';

/// The agency's listings whose seller agreement is running out.
class MandatesBloc extends Bloc<MandatesEvent, MandatesState>
    with SingleFlight, CollectionBloc<MandatesEvent, MandatesState> {
  final PropertiesRepository _repo;

  MandatesBloc(this._repo) : super(const MandatesInitial()) {
    on<MandatesLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(MandatesLoadEvent e, Emitter<MandatesState> emit) =>
      load(
        emit,
        keepVisible: state is MandatesLoaded,
        skeleton: const MandatesLoading(),
        fetch: _repo.getMandatesEnding,
        onData: MandatesLoaded.new,
        onFailure: MandatesError.new,
      );
}
