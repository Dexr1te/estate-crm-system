/// What money spent on a listing went on, as the server names it.
enum ExpenseCategory {
  photo('PHOTO'),
  advertising('ADVERTISING'),
  staging('STAGING'),
  cleaning('CLEANING'),
  legal('LEGAL'),
  other('OTHER');

  const ExpenseCategory(this.wire);

  final String wire;

  /// The category the server sent, or [other] for anything unknown.
  static ExpenseCategory fromWire(String? raw) {
    for (final c in values) {
      if (c.wire == raw) return c;
    }
    return other;
  }
}

DateTime _day(String raw) {
  final parsed = DateTime.parse(raw);
  return DateTime(parsed.year, parsed.month, parsed.day);
}

double _money(Object? raw) => (raw as num?)?.toDouble() ?? 0;

List<Map<String, dynamic>> _objects(Object? raw) => raw is List
    ? raw.whereType<Map<String, dynamic>>().toList()
    : const <Map<String, dynamic>>[];

/// A day as the server takes it: "2026-10-12".
String expenseDateParam(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// One payment for a listing, in the agency's currency.
class PropertyExpense {
  final int id;
  final int propertyId;
  final ExpenseCategory category;
  final double amount;
  final DateTime spentOn;
  final String? note;
  final int? createdById;
  final String? createdByName;
  final DateTime? createdAt;

  /// Whether the signed-in user may delete it: who recorded it, a manager or
  /// an admin.
  final bool canDelete;

  const PropertyExpense({
    required this.id,
    required this.propertyId,
    required this.category,
    required this.amount,
    required this.spentOn,
    this.note,
    this.createdById,
    this.createdByName,
    this.createdAt,
    this.canDelete = false,
  });

  factory PropertyExpense.fromJson(Map<String, dynamic> json) =>
      PropertyExpense(
        id: (json['id'] as num).toInt(),
        propertyId: (json['propertyId'] as num?)?.toInt() ?? 0,
        category: ExpenseCategory.fromWire(json['category'] as String?),
        amount: _money(json['amount']),
        spentOn: _day(json['spentOn'] as String),
        note: json['note'] as String?,
        createdById: (json['createdById'] as num?)?.toInt(),
        createdByName: json['createdByName'] as String?,
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        canDelete: (json['canDelete'] ?? false) as bool,
      );
}

/// What went on one category.
class ExpenseCategoryTotal {
  final ExpenseCategory category;
  final double total;

  const ExpenseCategoryTotal({required this.category, required this.total});

  factory ExpenseCategoryTotal.fromJson(Map<String, dynamic> json) =>
      ExpenseCategoryTotal(
        category: ExpenseCategory.fromWire(json['category'] as String?),
        total: _money(json['total']),
      );
}

/// The categories that have any, the largest first; ties in the enum's order.
List<ExpenseCategoryTotal> expenseTotalsByCategory(
    Iterable<PropertyExpense> items) {
  final sums = <ExpenseCategory, double>{};
  for (final e in items) {
    sums[e.category] = (sums[e.category] ?? 0) + e.amount;
  }
  final totals = [
    for (final c in ExpenseCategory.values)
      if ((sums[c] ?? 0) > 0) ExpenseCategoryTotal(category: c, total: sums[c]!)
  ];
  totals.sort((a, b) => b.total.compareTo(a.total) != 0
      ? b.total.compareTo(a.total)
      : a.category.index.compareTo(b.category.index));
  return totals;
}

/// What a listing has cost: every payment, the latest paid first, and the
/// sums.
class PropertyExpenses {
  final List<PropertyExpense> items;
  final double total;
  final List<ExpenseCategoryTotal> byCategory;

  const PropertyExpenses({
    this.items = const [],
    this.total = 0,
    this.byCategory = const [],
  });

  factory PropertyExpenses.fromJson(Map<String, dynamic> json) =>
      PropertyExpenses(
        items: _objects(json['items']).map(PropertyExpense.fromJson).toList(),
        total: _money(json['total']),
        byCategory: _objects(json['byCategory'])
            .map(ExpenseCategoryTotal.fromJson)
            .toList(),
      );

  /// The same list worked out again from [items], the way the server does:
  /// the latest paid first, the total, and the categories largest first.
  factory PropertyExpenses.of(Iterable<PropertyExpense> items) {
    final sorted = [...items]..sort((a, b) {
        final byDay = b.spentOn.compareTo(a.spentOn);
        return byDay != 0 ? byDay : b.id.compareTo(a.id);
      });
    return PropertyExpenses(
      items: sorted,
      total: sorted.fold<double>(0, (sum, e) => sum + e.amount),
      byCategory: expenseTotalsByCategory(sorted),
    );
  }

  PropertyExpenses adding(PropertyExpense expense) =>
      PropertyExpenses.of([expense, ...items]);

  PropertyExpenses removing(int expenseId) =>
      PropertyExpenses.of(items.where((e) => e.id != expenseId));
}

/// One of the listings that cost the most over a period.
class ExpenseListingTotal {
  final int propertyId;
  final String title;
  final double total;

  const ExpenseListingTotal({
    required this.propertyId,
    required this.title,
    required this.total,
  });

  factory ExpenseListingTotal.fromJson(Map<String, dynamic> json) =>
      ExpenseListingTotal(
        propertyId: (json['propertyId'] as num).toInt(),
        title: (json['title'] ?? '') as String,
        total: _money(json['total']),
      );
}

/// What was spent on listings over a period, both days included.
class ExpenseSummary {
  final DateTime? from;
  final DateTime? to;
  final double total;
  final List<ExpenseCategoryTotal> byCategory;

  /// At most five, the most first.
  final List<ExpenseListingTotal> topListings;

  const ExpenseSummary({
    this.from,
    this.to,
    this.total = 0,
    this.byCategory = const [],
    this.topListings = const [],
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) => ExpenseSummary(
        from: json['from'] is String ? _day(json['from'] as String) : null,
        to: json['to'] is String ? _day(json['to'] as String) : null,
        total: _money(json['total']),
        byCategory: _objects(json['byCategory'])
            .map(ExpenseCategoryTotal.fromJson)
            .toList(),
        topListings: _objects(json['topListings'])
            .map(ExpenseListingTotal.fromJson)
            .toList(),
      );
}

/// An expense as recorded from the app.
class ExpenseDraft {
  final ExpenseCategory category;
  final double amount;
  final DateTime spentOn;
  final String? note;

  const ExpenseDraft({
    required this.category,
    required this.amount,
    required this.spentOn,
    this.note,
  });

  /// The longest note the server keeps.
  static const maxNote = 500;

  /// Whether the server would take it on [today]: more than zero, paid no
  /// later than today, and a note that fits.
  bool isValidOn(DateTime today) =>
      amount > 0 &&
      !DateTime(spentOn.year, spentOn.month, spentOn.day)
          .isAfter(DateTime(today.year, today.month, today.day)) &&
      (note?.trim().length ?? 0) <= maxNote;

  Map<String, dynamic> toJson() {
    final trimmed = note?.trim() ?? '';
    return {
      'category': category.wire,
      'amount': amount,
      'spentOn': expenseDateParam(spentOn),
      if (trimmed.isNotEmpty) 'note': trimmed,
    };
  }
}
