import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/expense_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

DateTime _today() {
  final now = AppClock.now();
  return DateTime(now.year, now.month, now.day);
}

/// An amount as typed, to the cent: spaces and thousands commas go
/// ("45 000", "45,000"), and a comma with one or two digits after it and no
/// point is the decimal comma a Russian or Kazakh keyboard types ("45,50").
/// Zero when it is not a number.
double parseExpenseAmount(String text) {
  var s = text.replaceAll(RegExp(r'\s'), '');
  s = !s.contains('.') && RegExp(r'^\d*,\d{1,2}$').hasMatch(s)
      ? s.replaceAll(',', '.')
      : s.replaceAll(',', '');
  final value = double.tryParse(s) ?? 0;
  return (value * 100).roundToDouble() / 100;
}

/// Records what was spent on a listing; null when dismissed.
Future<ExpenseDraft?> showAddExpenseSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<ExpenseDraft>(
    context,
    title: l10n.expensesAddTitle,
    builder: (sheet) => ExpenseForm(
      onConfirm: (draft) => Navigator.pop(sheet, draft),
    ),
  );
}

/// What it was spent on, how much, the day it was paid (today or before) and
/// a note. Save stays off until the server would take it.
class ExpenseForm extends StatefulWidget {
  final ValueChanged<ExpenseDraft> onConfirm;

  const ExpenseForm({super.key, required this.onConfirm});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  ExpenseCategory? _category;
  DateTime _spentOn = _today();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  ExpenseDraft? get _draft {
    final category = _category;
    if (category == null) return null;
    return ExpenseDraft(
      category: category,
      amount: parseExpenseAmount(_amount.text),
      spentOn: _spentOn,
      note: _note.text,
    );
  }

  Future<void> _pickDate() async {
    final today = _today();
    final picked = await showDatePicker(
      context: context,
      initialDate: _spentOn,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
    );
    if (picked != null && mounted) setState(() => _spentOn = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final draft = _draft;
    final noteTooLong = _note.text.trim().length > ExpenseDraft.maxNote;
    final ready = draft != null && draft.isValidOn(_today()) ? draft : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        LabelledField(
          label: l10n.expensesCategory,
          required: true,
          child: FilterPillWrap(pills: [
            for (final c in ExpenseCategory.values)
              FilterPill(
                key: Key('expense-category-${c.name}'),
                label: expenseCategoryLabel(l10n, c),
                selected: _category == c,
                onTap: () => setState(() => _category = c),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.expensesAmount,
          required: true,
          child: AppTextField(
            key: const Key('expense-amount'),
            controller: _amount,
            hint: l10n.expensesAmountHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.expensesSpentOn,
          child: PickerField(
            key: const Key('expense-spent-on'),
            value: expenseDateLabel(_spentOn, AppClock.now(), locale),
            placeholder: l10n.expensesSpentOn,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: _pickDate,
          ),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.expensesNote,
          child: AppTextField(
            key: const Key('expense-note'),
            controller: _note,
            hint: l10n.expensesNoteHint,
            maxLines: 3,
            minLines: 1,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (noteTooLong) ...[
          const SizedBox(height: 6),
          Text(
            l10n.expensesNoteTooLong,
            key: const Key('expense-note-too-long'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11.5, color: t.dangerText),
          ),
        ],
        const SizedBox(height: 16),
        AppFilledButton(
          key: const Key('expense-save'),
          label: l10n.coreSave,
          onPressed: ready == null ? null : () => widget.onConfirm(ready),
        ),
      ],
    );
  }
}
