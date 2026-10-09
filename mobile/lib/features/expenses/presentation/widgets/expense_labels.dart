import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String expenseCategoryLabel(AppLocalizations l10n, ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.photo:
      return l10n.expensesCategoryPhoto;
    case ExpenseCategory.advertising:
      return l10n.expensesCategoryAdvertising;
    case ExpenseCategory.staging:
      return l10n.expensesCategoryStaging;
    case ExpenseCategory.cleaning:
      return l10n.expensesCategoryCleaning;
    case ExpenseCategory.legal:
      return l10n.expensesCategoryLegal;
    case ExpenseCategory.other:
      return l10n.expensesCategoryOther;
  }
}

/// A short date, with the year only when it is not this year's.
String expenseDateLabel(DateTime date, DateTime now, String locale) =>
    date.year == now.year
        ? formatDayMonth(date, locale)
        : formatFullDate(date, locale);
