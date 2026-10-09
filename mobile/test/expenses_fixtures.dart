import 'package:real_estate_crm/core/models/expense_models.dart';

/// The day the expenses tests run on.
final expensesNow = DateTime(2026, 9, 25, 15, 30);

/// Four payments on listing 7: 120,500 in all — staging 60,000, photography
/// 45,000 in two, advertising 15,500. The advertising is a colleague's, so
/// the signed-in user may not delete it.
List<PropertyExpense> expenseFixtures() => [
      PropertyExpense(
        id: 1,
        propertyId: 7,
        category: ExpenseCategory.photo,
        amount: 5000,
        spentOn: DateTime(2026, 9, 20),
        canDelete: true,
      ),
      PropertyExpense(
        id: 2,
        propertyId: 7,
        category: ExpenseCategory.photo,
        amount: 40000,
        spentOn: DateTime(2026, 9, 20),
        note: '40 shots, two drone',
        createdById: 5,
        createdByName: 'Maria Kim',
        canDelete: true,
      ),
      PropertyExpense(
        id: 3,
        propertyId: 7,
        category: ExpenseCategory.advertising,
        amount: 15500,
        spentOn: DateTime(2026, 9, 22),
        note: 'Krisha.kz, top for a week',
        createdById: 6,
        createdByName: 'Timur Aliev',
      ),
      PropertyExpense(
        id: 4,
        propertyId: 7,
        category: ExpenseCategory.staging,
        amount: 60000,
        spentOn: DateTime(2026, 9, 24),
        createdById: 5,
        createdByName: 'Maria Kim',
        canDelete: true,
      ),
    ];

/// The longest of everything: every category, big sums, long names and notes,
/// and a payment from last year.
List<PropertyExpense> longExpenseFixtures() => [
      for (final (i, c) in ExpenseCategory.values.indexed)
        PropertyExpense(
          id: 100 + i,
          propertyId: 7,
          category: c,
          amount: 987654321.0 / (i + 1),
          spentOn: i == 5 ? DateTime(2025, 12, 31) : DateTime(2026, 9, 20 - i),
          note: 'Paid by bank transfer to the contractor after the second '
              'visit, receipt in the documents folder',
          createdById: 5,
          createdByName: 'Aigerim Nurzhanovna Seitkaliyeva-Bekmukhambetova',
          canDelete: i.isEven,
        ),
    ];

/// September's spend: 185,000 — advertising 100,000, photography 60,000,
/// staging 25,000 — over two listings.
const summaryFixture = ExpenseSummary(
  total: 185000,
  byCategory: [
    ExpenseCategoryTotal(category: ExpenseCategory.advertising, total: 100000),
    ExpenseCategoryTotal(category: ExpenseCategory.photo, total: 60000),
    ExpenseCategoryTotal(category: ExpenseCategory.staging, total: 25000),
  ],
  topListings: [
    ExpenseListingTotal(
        propertyId: 12, title: 'Esentai City, apt 12', total: 120000),
    ExpenseListingTotal(
        propertyId: 7,
        title: 'Severny Residence, apartment 84 with a deliberately long name',
        total: 65000),
  ],
);

/// Every category and five listings with the longest titles.
final longSummaryFixture = ExpenseSummary(
  total: 2987654321,
  byCategory: [
    for (final (i, c) in ExpenseCategory.values.indexed)
      ExpenseCategoryTotal(category: c, total: 987654321.0 / (i + 1)),
  ],
  topListings: [
    for (var i = 0; i < 5; i++)
      ExpenseListingTotal(
          propertyId: 200 + i,
          title: 'Жилой комплекс «Северное сияние», квартира ${80 + i} с '
              'видом на горы и длинным названием',
          total: 98765432.0 / (i + 1)),
  ],
);
