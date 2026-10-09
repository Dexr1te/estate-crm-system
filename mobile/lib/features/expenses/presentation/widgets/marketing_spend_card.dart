import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/analytics_bar.dart';
import 'package:real_estate_crm/features/expenses/presentation/bloc/expense_summary_bloc.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/expense_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "Marketing spend" on the analytics screen: what was spent on listings over
/// the screen's period, in total and per category, and the listings that cost
/// the most. Reads an [ExpenseSummaryBloc] above it. A listing opens on tap;
/// [onOpenListing] replaces that, for a screen without a router.
class MarketingSpendCard extends StatelessWidget {
  final ValueChanged<int>? onOpenListing;

  const MarketingSpendCard({super.key, this.onOpenListing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ExpenseSummaryBloc, ExpenseSummaryState>(
      builder: (context, state) => AppCard(
        key: const ValueKey('marketing-spend'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EyebrowLabel(l10n.expensesSpendTitle),
            const SizedBox(height: 6),
            ..._body(context, state, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, ExpenseSummaryState state, AppLocalizations l10n) {
    final t = context.tokens;
    final secondary = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12.5,
        height: 1.35,
        color: t.textSecondary);

    if (state is ExpenseSummaryError) {
      return [
        Text(l10n.expensesSpendLoadFailed,
            maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
        const SizedBox(height: 10),
        AppGhostButton(
          key: const ValueKey('marketing-spend-retry'),
          label: l10n.coreRetry,
          height: AppMetrics.buttonHeightInline,
          onPressed: () => context
              .read<ExpenseSummaryBloc>()
              .add(ExpenseSummaryRetryEvent()),
        ),
      ];
    }
    if (state is! ExpenseSummaryLoaded) {
      return const [
        SizedBox(height: 6),
        ShimmerGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShimmerBar(widthFactor: 0.4, height: 18),
              SizedBox(height: 14),
              ShimmerBar(widthFactor: 0.9, height: 8),
              SizedBox(height: 12),
              ShimmerBar(widthFactor: 0.6, height: 8),
            ],
          ),
        ),
      ];
    }

    final s = state.summary;
    if (s.total <= 0) {
      return [
        Text(l10n.expensesSpendNone,
            key: const ValueKey('marketing-spend-none'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: secondary),
      ];
    }

    final heading = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: t.textHint);
    return [
      Text(l10n.expensesSpendHint,
          maxLines: 3, overflow: TextOverflow.ellipsis, style: secondary),
      const SizedBox(height: 12),
      Text(
        formatPrice(s.total),
        key: const ValueKey('marketing-spend-total'),
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
      const SizedBox(height: 16),
      Text(l10n.expensesByCategory,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: heading),
      for (final c in s.byCategory) ...[
        const SizedBox(height: 12),
        AnalyticsBarRow(
          key: ValueKey('marketing-spend-${c.category.name}'),
          label: expenseCategoryLabel(l10n, c.category),
          value: formatPrice(c.total),
          fraction: c.total / s.total,
          color: t.primary,
        ),
      ],
      if (s.topListings.isNotEmpty) ...[
        const SizedBox(height: 18),
        Text(l10n.expensesTopListings,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: heading),
        for (final listing in s.topListings) ...[
          const SizedBox(height: 8),
          _ListingRow(
            listing: listing,
            onTap: () => onOpenListing != null
                ? onOpenListing!(listing.propertyId)
                : context.push('/properties/${listing.propertyId}'),
          ),
        ],
      ],
    ];
  }
}

class _ListingRow extends StatelessWidget {
  final ExpenseListingTotal listing;
  final VoidCallback onTap;

  const _ListingRow({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final title = listing.title.trim().isEmpty
        ? '#${listing.propertyId}'
        : listing.title.trim();

    return AppCard(
      key: ValueKey('marketing-spend-listing-${listing.propertyId}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: t.textPrimary),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatPrice(listing.total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.textPrimary),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 18, color: t.textHint),
        ],
      ),
    );
  }
}
