import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/expenses/presentation/bloc/property_expenses_bloc.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/expense_labels.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/expense_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many expenses the card lists before "Show all".
const expensesRecentShown = 3;

/// What a listing has cost, on its detail screen: the total, the sum per
/// category, the latest payments and a way to record one. Each payment its
/// author, a manager or an admin may delete. Reads on its own, so the detail
/// screen only has to place it.
class PropertyExpensesCard extends StatefulWidget {
  final int propertyId;

  const PropertyExpensesCard({super.key, required this.propertyId});

  @override
  State<PropertyExpensesCard> createState() => _PropertyExpensesCardState();
}

class _PropertyExpensesCardState extends State<PropertyExpensesCard> {
  late final _bloc = PropertyExpensesBloc(Injector.expensesRepository,
      propertyId: widget.propertyId)
    ..add(PropertyExpensesLoadEvent());
  bool _showAll = false;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _add() async {
    final draft = await showAddExpenseSheet(context);
    if (draft != null && mounted) _bloc.add(PropertyExpensesAddEvent(draft));
  }

  Future<void> _delete(PropertyExpense e) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.expensesDeleteTitle,
      content: l10n.expensesDeleteBody(
          expenseCategoryLabel(l10n, e.category), formatPrice(e.amount)),
      confirmLabel: l10n.coreDelete,
    );
    if (ok && mounted) _bloc.add(PropertyExpensesDeleteEvent(e.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PropertyExpensesBloc, PropertyExpensesState>(
      bloc: _bloc,
      listenWhen: (prev, next) => next.outcome != null,
      listener: (context, state) => showActionOutcome(context, state.outcome),
      builder: (context, state) => AppCard(
        key: const ValueKey('property-expenses'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EyebrowLabel(l10n.expensesTitle),
            const SizedBox(height: 11),
            ..._body(context, state, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, PropertyExpensesState state,
      AppLocalizations l10n) {
    final t = context.tokens;
    final secondary = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12.5,
        height: 1.4,
        color: t.textSecondary);

    switch (state.status) {
      case PropertyExpensesStatus.loading:
        return const [
          ShimmerGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShimmerBar(widthFactor: 0.4, height: 18),
                SizedBox(height: 10),
                ShimmerBar(widthFactor: 0.8, height: 12),
                SizedBox(height: 8),
                ShimmerBar(widthFactor: 0.6, height: 12),
              ],
            ),
          ),
        ];
      case PropertyExpensesStatus.error:
        return [
          Text(l10n.expensesLoadFailed,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
          const SizedBox(height: 10),
          AppGhostButton(
            key: const ValueKey('property-expenses-retry'),
            label: l10n.coreRetry,
            height: AppMetrics.buttonHeightInline,
            onPressed: () => _bloc.add(PropertyExpensesLoadEvent()),
          ),
        ];
      case PropertyExpensesStatus.loaded:
        final expenses = state.expenses;
        final items = expenses.items;
        final shown =
            _showAll ? items : items.take(expensesRecentShown).toList();
        return [
          if (items.isEmpty)
            Text(l10n.expensesNone,
                key: const ValueKey('property-expenses-none'),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: secondary)
          else ...[
            Text(
              formatPrice(expenses.total),
              key: const ValueKey('property-expenses-total'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: t.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(l10n.expensesTotalCaption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    color: t.textSecondary)),
            const SizedBox(height: 12),
            for (final c in expenses.byCategory) ...[
              _CategoryLine(total: c),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 8),
            Text(l10n.expensesLatest,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: t.textHint)),
            for (final e in shown) ...[
              const SizedBox(height: 8),
              ExpenseRow(
                expense: e,
                onDelete:
                    e.canDelete && !state.saving ? () => _delete(e) : null,
              ),
            ],
            if (items.length > shown.length) ...[
              const SizedBox(height: 4),
              AppGhostButton(
                key: const ValueKey('property-expenses-show-all'),
                label: l10n.expensesShowAll(items.length),
                height: AppMetrics.minHitTarget,
                fontSize: 12.5,
                onPressed: () => setState(() => _showAll = true),
              ),
            ],
          ],
          const SizedBox(height: 12),
          AppGhostButton(
            key: const ValueKey('property-expenses-add'),
            label: l10n.expensesAdd,
            icon: Icons.receipt_long_outlined,
            loading: state.saving,
            onPressed: state.saving ? null : _add,
          ),
        ];
    }
  }
}

/// One category and what went on it: "Photography ... 45,000 ₸".
class _CategoryLine extends StatelessWidget {
  final ExpenseCategoryTotal total;
  const _CategoryLine({required this.total});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);
    return Row(
      key: ValueKey('property-expenses-category-${total.category.name}'),
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(expenseCategoryLabel(l10n, total.category),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
        const SizedBox(width: 8),
        Text(formatPrice(total.total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(
                fontWeight: FontWeight.w600, color: t.textPrimary)),
      ],
    );
  }
}

/// One payment: what it went on and how much, then the day, who recorded it
/// and the note; a delete button when [onDelete] is given. The amount sits
/// beside the category while both fit, and drops under it when they do not,
/// so a narrow screen or large text never cuts the sum.
class ExpenseRow extends StatelessWidget {
  final PropertyExpense expense;
  final VoidCallback? onDelete;

  const ExpenseRow({super.key, required this.expense, this.onDelete});

  /// The least room the category keeps beside the amount.
  static const _categoryRoom = 72.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final e = expense;
    final author = e.createdByName?.trim() ?? '';
    final note = e.note?.trim() ?? '';
    final details = [
      expenseDateLabel(e.spentOn, AppClock.now(), locale),
      if (author.isNotEmpty) author,
      if (note.isNotEmpty) note,
    ].join(' · ');
    final amountText = formatPrice(e.amount);
    final amountStyle = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: t.textPrimary);
    final category = Text(
      expenseCategoryLabel(l10n, e.category),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: t.textPrimary),
    );
    final amount = Text(amountText,
        maxLines: 1, overflow: TextOverflow.ellipsis, style: amountStyle);

    return AppCard(
      key: ValueKey('expense-row-${e.id}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding:
          EdgeInsetsDirectional.fromSTEB(12, 10, onDelete == null ? 12 : 2, 10),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final beside =
                  singleLineTextWidth(context, amountText, amountStyle) +
                          10 +
                          _categoryRoom <=
                      constraints.maxWidth;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (beside)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(child: category),
                        const SizedBox(width: 10),
                        amount,
                      ],
                    )
                  else ...[
                    category,
                    const SizedBox(height: 2),
                    amount,
                  ],
                  const SizedBox(height: 3),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        height: 1.35,
                        color: t.textSecondary),
                  ),
                ],
              );
            }),
          ),
          if (onDelete != null)
            AppIconTile(
              key: ValueKey('expense-delete-${e.id}'),
              icon: Icons.delete_outline_rounded,
              tooltip: l10n.coreDelete,
              onPressed: onDelete!,
            ),
        ],
      ),
    );
  }
}
