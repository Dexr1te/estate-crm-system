import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class ExpensesRemoteDataSource {
  final ApiClient _client;
  ExpensesRemoteDataSource(this._client);

  Future<PropertyExpenses> getForProperty(int propertyId) async {
    final res = await _client.dio.get('/properties/$propertyId/expenses');
    return PropertyExpenses.fromJson(jsonObject(res));
  }

  Future<PropertyExpense> create(int propertyId, ExpenseDraft draft) async {
    final res = await _client.dio
        .post('/properties/$propertyId/expenses', data: draft.toJson());
    return PropertyExpense.fromJson(jsonObject(res));
  }

  Future<void> delete(int propertyId, int expenseId) async {
    await _client.dio.delete('/properties/$propertyId/expenses/$expenseId');
  }

  Future<ExpenseSummary> getSummary(
      {required DateTime from, required DateTime to}) async {
    final res = await _client.dio.get('/expenses/summary', queryParameters: {
      'from': expenseDateParam(from),
      'to': expenseDateParam(to),
    });
    return ExpenseSummary.fromJson(jsonObject(res));
  }
}
