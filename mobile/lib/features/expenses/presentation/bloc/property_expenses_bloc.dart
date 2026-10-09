import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/expenses/domain/repositories/expenses_repository.dart';

abstract class PropertyExpensesEvent {}

class PropertyExpensesLoadEvent extends PropertyExpensesEvent {}

class PropertyExpensesAddEvent extends PropertyExpensesEvent {
  final ExpenseDraft draft;
  PropertyExpensesAddEvent(this.draft);
}

class PropertyExpensesDeleteEvent extends PropertyExpensesEvent {
  final int expenseId;
  PropertyExpensesDeleteEvent(this.expenseId);
}

enum PropertyExpensesStatus { loading, loaded, error }

/// A write the server refused; the list stays as it was.
class PropertyExpenseWriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  PropertyExpenseWriteFailed(this.failure);
}

class PropertyExpensesState {
  final PropertyExpensesStatus status;
  final PropertyExpenses expenses;
  final bool saving;

  /// Bumped on every write the server took.
  final int saved;
  final ApiFailure? loadFailure;
  final PropertyExpenseWriteFailed? outcome;

  const PropertyExpensesState({
    this.status = PropertyExpensesStatus.loading,
    this.expenses = const PropertyExpenses(),
    this.saving = false,
    this.saved = 0,
    this.loadFailure,
    this.outcome,
  });

  PropertyExpensesState copyWith({
    PropertyExpensesStatus? status,
    PropertyExpenses? expenses,
    bool? saving,
    int? saved,
    ApiFailure? loadFailure,
    PropertyExpenseWriteFailed? outcome,
  }) =>
      PropertyExpensesState(
        status: status ?? this.status,
        expenses: expenses ?? this.expenses,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        loadFailure: loadFailure ?? this.loadFailure,
        outcome: outcome,
      );
}

/// The expenses of one listing, and what is recorded or deleted from its
/// card. A write the server took is applied to the list here, totals and all,
/// so the card does not have to read the listing again.
class PropertyExpensesBloc
    extends Bloc<PropertyExpensesEvent, PropertyExpensesState> {
  final ExpensesRepository _repo;
  final int propertyId;

  PropertyExpensesBloc(this._repo, {required this.propertyId})
      : super(const PropertyExpensesState()) {
    on<PropertyExpensesLoadEvent>(_onLoad);
    on<PropertyExpensesAddEvent>((e, emit) => _write(emit, () async {
          final saved = await _repo.create(propertyId, e.draft);
          return state.expenses.adding(saved);
        }));
    on<PropertyExpensesDeleteEvent>((e, emit) => _write(emit, () async {
          await _repo.delete(propertyId, e.expenseId);
          return state.expenses.removing(e.expenseId);
        }));
  }

  Future<void> _onLoad(
      PropertyExpensesLoadEvent e, Emitter<PropertyExpensesState> emit) async {
    if (state.status != PropertyExpensesStatus.loaded) {
      emit(state.copyWith(status: PropertyExpensesStatus.loading));
    }
    try {
      final expenses = await _repo.getForProperty(propertyId);
      emit(state.copyWith(
          status: PropertyExpensesStatus.loaded, expenses: expenses));
    } catch (error) {
      final failure = ApiFailure.from(error);
      emit(state.status == PropertyExpensesStatus.loaded
          ? state.copyWith(outcome: PropertyExpenseWriteFailed(failure))
          : state.copyWith(
              status: PropertyExpensesStatus.error, loadFailure: failure));
    }
  }

  Future<void> _write(Emitter<PropertyExpensesState> emit,
      Future<PropertyExpenses> Function() call) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final next = await call();
      emit(state.copyWith(
          expenses: next, saving: false, saved: state.saved + 1));
    } catch (error) {
      emit(state.copyWith(
          saving: false,
          outcome: PropertyExpenseWriteFailed(ApiFailure.from(error))));
    }
  }
}
