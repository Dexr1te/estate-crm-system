import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/payout_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/payouts/domain/repositories/payouts_repository.dart';

abstract class PayoutsEvent {}

/// Loads the tab on screen again: on opening, pulling down, coming back
/// from a deal.
class PayoutsLoadEvent extends PayoutsEvent {}

/// Unpaid or paid shares.
class PayoutsTabChanged extends PayoutsEvent {
  final PayoutStatus tab;
  PayoutsTabChanged(this.tab);
}

enum PayoutsLoad { loading, loaded, error }

class PayoutsState {
  final PayoutStatus tab;
  final PayoutsLoad load;

  /// The last list the server sent. While another tab loads it is still the
  /// previous tab's, so its totals stay on screen; its items are only shown
  /// once [load] is [PayoutsLoad.loaded].
  final PayoutList? list;
  final ApiFailure? failure;

  const PayoutsState({
    this.tab = PayoutStatus.unpaid,
    this.load = PayoutsLoad.loading,
    this.list,
    this.failure,
  });
}

/// The payouts screen: the shares of won deals, unpaid or paid, with what is
/// owed and paid in all.
class PayoutsBloc extends Bloc<PayoutsEvent, PayoutsState> {
  final PayoutsRepository _repo;
  int _request = 0;

  PayoutsBloc(this._repo) : super(const PayoutsState()) {
    on<PayoutsLoadEvent>((e, emit) => _load(emit, state.tab));
    on<PayoutsTabChanged>((e, emit) async {
      if (e.tab == state.tab && state.load == PayoutsLoad.loaded) return;
      await _load(emit, e.tab);
    });
  }

  Future<void> _load(Emitter<PayoutsState> emit, PayoutStatus tab) async {
    final request = ++_request;
    emit(PayoutsState(tab: tab, load: PayoutsLoad.loading, list: state.list));
    try {
      final list = await _repo.getPayouts(status: tab);
      if (request != _request) return;
      emit(PayoutsState(tab: tab, load: PayoutsLoad.loaded, list: list));
    } catch (error) {
      if (request != _request) return;
      emit(PayoutsState(
          tab: tab,
          load: PayoutsLoad.error,
          list: state.list,
          failure: ApiFailure.from(error)));
    }
  }
}
