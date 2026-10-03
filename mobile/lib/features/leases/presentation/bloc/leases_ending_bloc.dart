import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/domain/repositories/leases_repository.dart';

abstract class LeasesEndingEvent {}

/// Loads, or reloads, the leases running out.
class LeasesEndingLoadEvent extends LeasesEndingEvent {}

abstract class LeasesEndingState {
  const LeasesEndingState();
}

class LeasesEndingInitial extends LeasesEndingState {
  const LeasesEndingInitial();
}

class LeasesEndingLoading extends LeasesEndingState {
  const LeasesEndingLoading();
}

/// Soonest first, as the server sends them.
class LeasesEndingLoaded extends LeasesEndingState {
  final List<LeaseEnding> leases;
  const LeasesEndingLoaded(this.leases);
}

class LeasesEndingError extends LeasesEndingState {
  final ApiFailure failure;
  const LeasesEndingError(this.failure);
}

/// Won rents whose lease ends within [kLeaseWindowDays] of the phone's today.
class LeasesEndingBloc extends Bloc<LeasesEndingEvent, LeasesEndingState>
    with SingleFlight, CollectionBloc<LeasesEndingEvent, LeasesEndingState> {
  final LeasesRepository _repo;

  LeasesEndingBloc(this._repo) : super(const LeasesEndingInitial()) {
    on<LeasesEndingLoadEvent>((e, emit) => load(
          emit,
          keepVisible: state is LeasesEndingLoaded,
          skeleton: const LeasesEndingLoading(),
          fetch: () => _repo.getLeasesEnding(
              days: kLeaseWindowDays, from: AppClock.now()),
          onData: LeasesEndingLoaded.new,
          onFailure: LeasesEndingError.new,
        ));
  }
}
