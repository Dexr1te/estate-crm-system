import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/auth_bloc.dart';
import 'package:real_estate_crm/features/dashboard/dashboard_bloc.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (ctx, state) {
            return RefreshIndicator(
              onRefresh: () async =>
                  ctx.read<DashboardBloc>().add(DashboardLoadEvent()),
              color: Theme.of(context).colorScheme.primary,
              child: CustomScrollView(slivers: [
                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            'Hey, ${user?.fullName.split(' ').first ?? 'there'} ✨',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Sora'),
                          ),
                          const SizedBox(height: 4),
                          Text("Here's your overview",
                              style: Theme.of(context).textTheme.bodySmall),
                        ])),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: _UserAvatar(name: user?.fullName ?? '?'),
                    ),
                  ]),
                )),

                if (state is DashboardLoading)
                  SliverToBoxAdapter(child: _DashboardSkeleton())
                else if (state is DashboardError)
                  SliverFillRemaining(
                      child: ErrorWidget2(
                          message: state.message,
                          onRetry: () => ctx
                              .read<DashboardBloc>()
                              .add(DashboardLoadEvent())))
                else if (state is DashboardLoaded) ...[
                  SliverToBoxAdapter(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Overview',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                            children: [
                              StatCard(
                                  label: 'Total Deals',
                                  value: '${state.summary.totalDeals}',
                                  icon: Icons.handshake_outlined,
                                  color: AppColors.error,
                                  subtitle:
                                      '${state.summary.activeDeals} active'),
                              StatCard(
                                  label: 'Clients',
                                  value: '${state.summary.totalClients}',
                                  icon: Icons.people_outline,
                                  color: AppColors.info),
                              StatCard(
                                  label: 'Closed Won',
                                  value: '${state.summary.closedDeals}',
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.success),
                              StatCard(
                                  label: 'Upcoming',
                                  value: '${state.summary.upcomingMeetings}',
                                  icon: Icons.calendar_today_outlined,
                                  color: AppColors.accent,
                                  subtitle: 'meetings'),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Upcoming Meetings',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                TextButton(
                                    onPressed: () => context.go('/meetings'),
                                    child: const Text('See all')),
                              ]),
                          const SizedBox(height: 8),
                        ]),
                  )),
                  if (state.upcoming.isEmpty)
                    const SliverToBoxAdapter(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(children: [
                                Icon(Icons.calendar_today_outlined,
                                    color: AppColors.textHint),
                                SizedBox(width: 12),
                                Text('No upcoming meetings'),
                              ]))),
                    ))
                  else
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        child: Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(children: [
                                  Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withAlpha(20),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Icon(Icons.calendar_today,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 20)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(state.upcoming[i].title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        Text(state.upcoming[i].clientName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ])),
                                  Text(
                                      formatDateTime(
                                          state.upcoming[i].scheduledAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall),
                                ]))),
                      ),
                      childCount: state.upcoming.length,
                    )),
                  SliverToBoxAdapter(
                      child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quick Actions',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: _QuickAction(
                                    icon: Icons.person_add_outlined,
                                    label: 'Add Client',
                                    color: AppColors.info,
                                    onTap: () => context.go('/clients/new'))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _QuickAction(
                                    icon: Icons.add_home_outlined,
                                    label: 'Add Property',
                                    color: AppColors.accent,
                                    onTap: () =>
                                        context.go('/properties/new'))),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: _QuickAction(
                                    icon: Icons.handshake_outlined,
                                    label: 'New Deal',
                                    color: AppColors.lead,
                                    onTap: () => context.go('/deals/new'))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _QuickAction(
                                    icon: Icons.event_outlined,
                                    label: 'Schedule Meeting',
                                    color: AppColors.success,
                                    onTap: () => context.go('/meetings/new'))),
                          ]),
                        ]),
                  )),
                ],
              ]),
            );
          },
        ),
      ),
    );
  }
}

// ─── Dashboard Skeleton ──────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252A3D) : const Color(0xFFE8ECF4);
    final highlight =
        isDark ? const Color(0xFF353B52) : const Color(0xFFF5F7FC);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // "Overview" label
          const ShimmerBox(width: 80, height: 16, radius: 8),
          const SizedBox(height: 16),
          // Stats grid — 2x2
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: List.generate(4, (_) => const _StatCardSkeleton()),
          ),
          const SizedBox(height: 28),
          // "Upcoming Meetings" row
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 160, height: 16, radius: 8),
                ShimmerBox(width: 50, height: 14, radius: 7),
              ]),
          const SizedBox(height: 12),
          // 3 meeting skeletons
          ...List.generate(
              3,
              (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(children: [
                          ShimmerBox(width: 44, height: 44, radius: 10),
                          SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                ShimmerBox(
                                    width: double.infinity,
                                    height: 14,
                                    radius: 7),
                                SizedBox(height: 6),
                                ShimmerBox(width: 120, height: 12, radius: 6),
                              ])),
                          SizedBox(width: 12),
                          ShimmerBox(width: 60, height: 11, radius: 5),
                        ]),
                      ),
                    ),
                  )),
          const SizedBox(height: 8),
          // "Quick Actions" label
          const ShimmerBox(width: 110, height: 16, radius: 8),
          const SizedBox(height: 12),
          // Quick action rows
          Row(children: [
            Expanded(child: _QuickActionSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _QuickActionSkeleton()),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _QuickActionSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _QuickActionSkeleton()),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShimmerBox(width: 36, height: 36, radius: 10),
            SizedBox(height: 12),
            Row(children: [
              ShimmerBox(width: 40, height: 26, radius: 6),
              SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ShimmerBox(width: 70, height: 12, radius: 6),
                SizedBox(height: 4),
                ShimmerBox(width: 50, height: 10, radius: 5),
              ]),
            ]),
          ]),
        ),
      );
}

class _QuickActionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [
            ShimmerBox(width: 36, height: 36, radius: 10),
            SizedBox(width: 12),
            ShimmerBox(width: 80, height: 13, radius: 6),
          ]),
        ),
      );
}

// ─── User Avatar ─────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final String name;
  const _UserAvatar({required this.name});

  Color _color(String n) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.success,
      const Color(0xFF8B5CF6),
      AppColors.info
    ];
    return n.isNotEmpty
        ? colors[n.codeUnitAt(0) % colors.length]
        : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(name);
    return Hero(
      tag: 'user_avatar',
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(38),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Sora'),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: color.withAlpha(31),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: color, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600))),
                ]))),
      );
}
