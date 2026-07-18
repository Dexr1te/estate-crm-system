import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_state.dart';
import 'package:real_estate_crm/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/bloc/dashboard_event.dart';
import 'package:real_estate_crm/features/dashboard/bloc/dashboard_state.dart';
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Still up';
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                              '${_greeting()}, ${user?.fullName.split(' ').first ?? 'there'} ✨',
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Sora'),
                            ),
                            const SizedBox(height: 4),
                            Text("Here's your overview for today",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(letterSpacing: 0.1)),
                          ])),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: _UserAvatar(name: user?.fullName ?? '?'),
                      ),
                    ],
                  ),
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(title: 'Overview'),
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 30),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const _SectionHeader(
                                    title: 'Upcoming Meetings'),
                                TextButton.icon(
                                    onPressed: () => context.go('/meetings'),
                                    icon: const Text('See all',
                                        style: TextStyle(fontSize: 13)),
                                    label: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 15),
                                    iconAlignment: IconAlignment.end,
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap)),
                              ]),
                          const SizedBox(height: 10),
                        ]),
                  )),
                  if (state.upcoming.isEmpty)
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withAlpha(90),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withAlpha(40)),
                        ),
                        child: Column(children: [
                          Icon(Icons.event_available_outlined,
                              color: AppColors.textHint, size: 30),
                          const SizedBox(height: 10),
                          Text('No upcoming meetings',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textHint)),
                        ]),
                      ),
                    ))
                  else
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                        child: _MeetingTile(
                          title: state.upcoming[i].title,
                          clientName: state.upcoming[i].clientName,
                          time: formatDateTime(state.upcoming[i].scheduledAt),
                        ),
                      ),
                      childCount: state.upcoming.length,
                    )),
                  SliverToBoxAdapter(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(title: 'Quick Actions'),
                          const SizedBox(height: 14),
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

// ─── Section Header ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: 'Sora'));
}

// ─── Meeting Tile ────────────────────────────────────────────────

class _MeetingTile extends StatelessWidget {
  final String title;
  final String clientName;
  final String time;
  const _MeetingTile(
      {required this.title, required this.clientName, required this.time});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: primary,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12)),
                    child:
                        Icon(Icons.calendar_today, color: primary, size: 18)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(clientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                    ])),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(140),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(time,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          ),
        ]),
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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const ShimmerBox(width: 80, height: 16, radius: 8),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: List.generate(4, (_) => const _StatCardSkeleton()),
          ),
          const SizedBox(height: 30),
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 160, height: 16, radius: 8),
                ShimmerBox(width: 50, height: 14, radius: 7),
              ]),
          const SizedBox(height: 14),
          ...List.generate(
              3,
              (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(children: [
                          ShimmerBox(width: 42, height: 42, radius: 12),
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
                          ShimmerBox(width: 50, height: 20, radius: 8),
                        ]),
                      ),
                    ),
                  )),
          const SizedBox(height: 16),
          const ShimmerBox(width: 110, height: 16, radius: 8),
          const SizedBox(height: 14),
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
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withAlpha(60), color.withAlpha(20)],
          ),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(60),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Sora'),
          ),
        ),
      ),
    );
  }
}

// ─── Quick Action ────────────────────────────────────────────────

class _QuickAction extends StatefulWidget {
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
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withAlpha(45), width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Row(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: widget.color.withAlpha(31),
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(widget.icon, color: widget.color, size: 19)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(widget.label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
        ),
      ),
    );
  }
}
