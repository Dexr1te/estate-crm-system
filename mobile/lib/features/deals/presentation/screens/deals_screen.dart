import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_card.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_filter_tab.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

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
                  DealFilterTab(
                      label: 'All',
                      selected: _filter == null,
                      isDark: isDark,
                      onTap: () {
                        setState(() => _filter = null);
                        context.read<DealsBloc>().add(DealsLoadEvent());
                      }),
                  ...DealStatus.values.map((s) => DealFilterTab(
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
                  itemBuilder: (_, i) => DealCard(
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
