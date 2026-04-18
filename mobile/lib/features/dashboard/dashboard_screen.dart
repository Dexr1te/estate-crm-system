import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/auth_bloc.dart';
import 'package:real_estate_crm/features/dashboard/dashboard_bloc.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (ctx, state) {
            return RefreshIndicator(
              onRefresh: () async =>
                  ctx.read<DashboardBloc>().add(DashboardLoadEvent()),
              color: AppColors.primary,
              child: CustomScrollView(slivers: [
                // ── Header with Avatar ──────────────────────────
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                              'Hello, ${user?.fullName.split(' ').first ?? 'there'} 👋',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontFamily: 'Sora'),
                            ),
                            const SizedBox(height: 4),
                            const Text("Here's your overview",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ])),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: _UserAvatar(name: user?.fullName ?? '?'),
                      ),
                    ],
                  ),
                )),

                if (state is DashboardLoading)
                  const SliverFillRemaining(child: LoadingWidget())
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
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
                                  color: AppColors.primary,
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
                                      fontWeight: FontWeight.w600,
                                    )),
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
                                Text('No upcoming meetings',
                                    style: TextStyle()),
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
                                          color: AppColors.primary
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Icon(Icons.calendar_today,
                                          color: AppColors.primary, size: 20)),
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
                                            style: const TextStyle(
                                              fontSize: 13,
                                            )),
                                      ])),
                                  Text(
                                      formatDateTime(
                                          state.upcoming[i].scheduledAt),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint)),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
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
          color: color.withOpacity(0.15),
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
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: color, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ))),
                ]))),
      );
}
