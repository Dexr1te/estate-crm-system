import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/deposits/domain/repositories/deposits_repository.dart';

abstract class DepositsEndingEvent {}

/// Loads, or reloads, the deposits whose hold is running out.
class DepositsEndingLoadEvent extends DepositsEndingEvent {}

abstract class DepositsEndingState {
  const DepositsEndingState();
}

class DepositsEndingInitial extends DepositsEndingState {
  const DepositsEndingInitial();
}

class DepositsEndingLoading extends DepositsEndingState {
  const DepositsEndingLoading();
}

/// Soonest (or longest gone) first, as the server sends them.
class DepositsEndingLoaded extends DepositsEndingState {
  final List<DealDeposit> deposits;
  const DepositsEndingLoaded(this.deposits);
}

class DepositsEndingError extends DepositsEndingState {
  final ApiFailure failure;
  const DepositsEndingError(this.failure);
}

/// Active deposits whose hold ends within a week or has ended.
class DepositsEndingBloc extends Bloc<DepositsEndingEvent, DepositsEndingState>
    with
        SingleFlight,
        CollectionBloc<DepositsEndingEvent, DepositsEndingState> {
  final DepositsRepository _repo;

  DepositsEndingBloc(this._repo) : super(const DepositsEndingInitial()) {
    on<DepositsEndingLoadEvent>((e, emit) => load(
          emit,
          keepVisible: state is DepositsEndingLoaded,
          skeleton: const DepositsEndingLoading(),
          fetch: _repo.getDepositsEnding,
          onData: DepositsEndingLoaded.new,
          onFailure: DepositsEndingError.new,
        ));
  }
}
