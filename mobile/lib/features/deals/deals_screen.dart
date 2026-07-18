import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/deals/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/bloc/deals_state.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});
  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  DealStatus? _filter;

  @override
  void initState() {
    super.initState();
    context.read<DealsBloc>().add(DealsLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(children: [
            Expanded(
                child: Text('Deals',
                    style: tt.titleLarge?.copyWith(fontSize: 22))),
            FilledButton.icon(
              onPressed: () => context.go('/deals/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Deal'),
              style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ]),
        ),
        SizedBox(
            height: 40,
            child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _FilterTab(
                      label: 'All',
                      selected: _filter == null,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _filter = null);
                        context.read<DealsBloc>().add(DealsLoadEvent());
                      }),
                  ...DealStatus.values.map((s) => _FilterTab(
                      label: s.name.replaceAll('_', ' '),
                      selected: _filter == s,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _filter = s);
                        context
                            .read<DealsBloc>()
                            .add(DealsLoadEvent(status: s));
                      })),
                ])),
        const SizedBox(height: 12),
        Expanded(
            child: BlocConsumer<DealsBloc, DealsState>(
          listener: (ctx, state) {
            if (state is DealsError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error));
            }
            if (state is DealsActionSuccess) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            if (state is DealsLoading) {
              return ShimmerList(cardBuilder: () => const DealCardSkeleton());
            }
            if (state is DealsError) {
              return ErrorWidget2(
                  message: state.message,
                  onRetry: () => ctx.read<DealsBloc>().add(DealsLoadEvent()));
            }
            if (state is DealsLoaded) {
              if (state.deals.isEmpty) {
                return const EmptyState(
                    title: 'No deals',
                    icon: Icons.handshake_outlined,
                    subtitle: 'Start your pipeline');
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ctx.read<DealsBloc>().add(DealsLoadEvent()),
                color: cs.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: state.deals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _DealCard(
                      deal: state.deals[i],
                      onTap: () => context.go('/deals/${state.deals[i].id}')),
                ),
              );
            }
            return const SizedBox();
          },
        )),
      ])),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _FilterTab(
      {required this.label,
      required this.selected,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final unselectedBorder =
        isDark ? AppColors.darkBorder : const Color(0xFFE8ECF4);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? cs.primary : unselectedBg,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: selected ? cs.primary : unselectedBorder),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                    color: selected ? Colors.white : tt.bodySmall?.color)),
          )),
    );
  }
}

class _DealCard extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback onTap;
  const _DealCard({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(deal.title,
                        style: tt.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600))),
                DealStatusChip(status: deal.status),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.person_outline,
                    size: 14, color: tt.bodySmall?.color),
                const SizedBox(width: 4),
                Text(deal.clientName, style: tt.bodySmall),
                if (deal.propertyTitle != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.home_outlined,
                      size: 14, color: tt.bodySmall?.color),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(deal.propertyTitle!,
                          style: tt.bodySmall,
                          overflow: TextOverflow.ellipsis)),
                ],
              ]),
              if (deal.dealPrice != null || deal.budget != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  if (deal.dealPrice != null) ...[
                    const Icon(Icons.attach_money,
                        size: 14, color: AppColors.success),
                    Text(formatPrice(deal.dealPrice!),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success))
                  ],
                  if (deal.budget != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 14, color: tt.bodySmall?.color),
                    Text('Budget: ${formatPrice(deal.budget!)}',
                        style: tt.bodySmall)
                  ],
                ]),
              ],
              const SizedBox(height: 4),
              Text('Agent: ${deal.agentName}', style: tt.labelSmall),
            ]),
          )),
    );
  }
}
