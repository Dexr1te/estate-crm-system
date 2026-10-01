import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/client_dates_repository.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_state.dart';

/// Birthdays and purchase anniversaries in the next [days] days, counted from
/// the phone's today.
class ClientDatesBloc extends Bloc<ClientDatesEvent, ClientDatesState>
    with SingleFlight, CollectionBloc<ClientDatesEvent, ClientDatesState> {
  final ClientDatesRepository _repo;
  final int days;

  ClientDatesBloc(this._repo, {this.days = ClientDatesRepository.defaultDays})
      : super(const ClientDatesInitial()) {
    on<ClientDatesLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(
          ClientDatesLoadEvent e, Emitter<ClientDatesState> emit) =>
      load(
        emit,
        keepVisible: state is ClientDatesLoaded,
        skeleton: const ClientDatesLoading(),
        fetch: () => _repo.getUpcoming(from: AppClock.now(), days: days),
        onData: (List<UpcomingClientDate> dates) => ClientDatesLoaded(
            dates.where((d) => d.kind != ClientDateKind.unknown).toList()),
        onFailure: ClientDatesError.new,
      );
}
