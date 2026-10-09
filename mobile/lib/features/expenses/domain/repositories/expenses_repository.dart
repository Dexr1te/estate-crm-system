import 'package:real_estate_crm/core/models/expense_models.dart';

abstract class ExpensesRepository {
  /// A listing's expenses, the latest paid first, with the total and the sum
  /// per category.
  Future<PropertyExpenses> getForProperty(int propertyId);

  Future<PropertyExpense> create(int propertyId, ExpenseDraft draft);

  Future<void> delete(int propertyId, int expenseId);

  /// What was spent on the listings the caller counts over [from]..[to],
  /// both days included.
  Future<ExpenseSummary> getSummary(
      {required DateTime from, required DateTime to});
}
