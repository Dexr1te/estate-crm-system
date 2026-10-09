import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/features/expenses/data/datasources/expenses_remote_datasource.dart';
import 'package:real_estate_crm/features/expenses/domain/repositories/expenses_repository.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource _remote;
  ExpensesRepositoryImpl(this._remote);

  @override
  Future<PropertyExpenses> getForProperty(int propertyId) =>
      _remote.getForProperty(propertyId);

  @override
  Future<PropertyExpense> create(int propertyId, ExpenseDraft draft) =>
      _remote.create(propertyId, draft);

  @override
  Future<void> delete(int propertyId, int expenseId) =>
      _remote.delete(propertyId, expenseId);

  @override
  Future<ExpenseSummary> getSummary(
          {required DateTime from, required DateTime to}) =>
      _remote.getSummary(from: from, to: to);
}
