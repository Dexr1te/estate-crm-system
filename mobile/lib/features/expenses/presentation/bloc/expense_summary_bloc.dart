import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/expenses/domain/repositories/expenses_repository.dart';

abstract class ExpenseSummaryEvent {}

/// Reads what was spent over [from]..[to], both days included.
class ExpenseSummaryLoadEvent extends ExpenseSummaryEvent {
  final DateTime from;
  final DateTime to;
  ExpenseSummaryLoadEvent({required this.from, required this.to});
}

/// Reads the last period again.
class ExpenseSummaryRetryEvent extends ExpenseSummaryEvent {}

abstract class ExpenseSummaryState {
  const ExpenseSummaryState();
}

class ExpenseSummaryLoading extends ExpenseSummaryState {
  const ExpenseSummaryLoading();
}

class ExpenseSummaryLoaded extends ExpenseSummaryState {
  final ExpenseSummary summary;
  const ExpenseSummaryLoaded(this.summary);
}

class ExpenseSummaryError extends ExpenseSummaryState {
  final ApiFailure failure;
  const ExpenseSummaryError(this.failure);
}

/// What the agency spent on its listings over the period a screen shows. Only
/// the latest period asked for is ever shown, however the answers arrive.
class ExpenseSummaryBloc
    extends Bloc<ExpenseSummaryEvent, ExpenseSummaryState> {
  final ExpensesRepository _repo;
  int _request = 0;
  (DateTime, DateTime)? _period;

  ExpenseSummaryBloc(this._repo) : super(const ExpenseSummaryLoading()) {
    on<ExpenseSummaryLoadEvent>((e, emit) => _load(emit, (e.from, e.to)));
    on<ExpenseSummaryRetryEvent>((e, emit) async {
      final period = _period;
      if (period != null) await _load(emit, period);
    });
  }

  Future<void> _load(
      Emitter<ExpenseSummaryState> emit, (DateTime, DateTime) period) async {
    final request = ++_request;
    _period = period;
    emit(const ExpenseSummaryLoading());
    try {
      final summary = await _repo.getSummary(from: period.$1, to: period.$2);
      if (request != _request) return;
      emit(ExpenseSummaryLoaded(summary));
    } catch (error) {
      if (request != _request) return;
      emit(ExpenseSummaryError(ApiFailure.from(error)));
    }
  }
}
