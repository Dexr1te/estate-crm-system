import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/presentation/bloc/route_bloc.dart';
import 'package:real_estate_crm/features/route/presentation/widgets/maps_chooser_sheet.dart';
import 'package:real_estate_crm/features/route/presentation/widgets/route_map.dart';
import 'package:real_estate_crm/features/route/presentation/widgets/route_stop_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A day's viewings as one route: pins in the order of the schedule, the
/// list under it, and the way out to a maps app.
class RouteScreen extends StatefulWidget {
  final DateTime day;

  const RouteScreen({super.key, required this.day});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  late final RouteBloc _bloc =
      RouteBloc(Injector.dayRouteRepository, widget.day)..add(RouteLoadEvent());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _go(String location) async {
    await context.push(location);
    if (mounted) _bloc.add(RouteLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return BlocBuilder<RouteBloc, RouteState>(
      bloc: _bloc,
      builder: (context, state) => DetailScaffold(
        title: l10n.routeTitle,
        trailingLabel: formatDayMonth(widget.day, locale),
        onRefresh: () async => _bloc.add(RouteLoadEvent()),
        children: _body(context, l10n, state),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, AppLocalizations l10n, RouteState state) {
    final route = state.route;
    if (route == null && state.failure != null) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.routeLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure!),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(RouteLoadEvent())),
        ),
      ];
    }
    if (route == null) return const [_RouteSkeleton()];
    if (route.isEmpty) {
      return [
        EmptyState(
          icon: Icons.route_outlined,
          title: l10n.routeEmpty,
          subtitle: l10n.routeEmptyHint,
        ),
      ];
    }
    final now = AppClock.now();
    return [
      if (route.legs.isNotEmpty) _mapCard(context, l10n, route, now),
      if (route.legs.isNotEmpty) _stops(route, now),
      if (route.unlocated.isNotEmpty) _unlocated(l10n, route, now),
    ];
  }

  Widget _mapCard(BuildContext context, AppLocalizations l10n, DayRoute route,
      DateTime now) {
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final next = route.nextFrom(now);
    final remaining = route.remainingFrom(now);
    final hint = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12, color: t.textSecondary);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.routeSummary(l10n.routeStopsCount(route.legs.length),
                formatKm(route.totalKm, locale)),
            key: const ValueKey('route-summary'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: t.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(l10n.routeStraightLine,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: hint),
          const SizedBox(height: 12),
          RouteMap(legs: route.legs, next: next, now: now),
          const SizedBox(height: 12),
          if (next != null)
            AppFilledButton(
              key: const ValueKey('route-navigate-next'),
              label: l10n.routeNavigateNext,
              onPressed: () =>
                  showMapsChooser(context, stops: [next], whole: false),
            )
          else
            Text(l10n.routeDayOver,
                key: const ValueKey('route-day-over'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: hint),
          if (remaining.length > 1) ...[
            const SizedBox(height: 8),
            AppGhostButton(
              key: const ValueKey('route-open-whole'),
              label: l10n.routeOpenWhole,
              icon: Icons.alt_route_rounded,
              onPressed: () =>
                  showMapsChooser(context, stops: remaining, whole: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stops(DayRoute route, DateTime now) {
    final next = route.nextFrom(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final leg in route.legs) ...[
          RouteStopRow(
            key: ValueKey('route-stop-${leg.number}'),
            leg: leg,
            stop: leg.stop,
            now: now,
            isNext: identical(leg, next),
            onTap: () => _go('/meetings/${leg.stop.meeting.id}'),
          ),
          RouteGap(leg: leg),
        ],
      ],
    );
  }

  Widget _unlocated(AppLocalizations l10n, DayRoute route, DateTime now) {
    final t = context.tokens;
    return Column(
      key: const ValueKey('route-not-on-map'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.routeNotOnMap, count: route.unlocated.length),
        const SizedBox(height: 4),
        Text(l10n.routeNotOnMapHint,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12,
                color: t.textSecondary)),
        const SizedBox(height: 10),
        for (final stop in route.unlocated) ...[
          RouteStopRow(
            key: ValueKey('route-unlocated-${stop.meeting.id}'),
            stop: stop,
            now: now,
            onTap: () => _go('/meetings/${stop.meeting.id}'),
            footer: AppGhostButton(
              key: ValueKey('route-add-pin-${stop.meeting.propertyId}'),
              label: l10n.routeAddPin,
              icon: Icons.edit_location_alt_outlined,
              height: AppMetrics.minHitTarget,
              onPressed: () =>
                  _go('/properties/${stop.meeting.propertyId}/edit'),
            ),
          ),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _RouteSkeleton extends StatelessWidget {
  const _RouteSkeleton();

  @override
  Widget build(BuildContext context) => ShimmerGroup(
        child: Column(
          children: [
            const ShimmerCard(
              height: 330,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShimmerCircle(size: StopNumber.size),
                  ShimmerCircle(size: StopNumber.size),
                  ShimmerCircle(size: StopNumber.size),
                ],
              ),
            ),
            for (var i = 0; i < 3; i++) ...[
              const SizedBox(height: 9),
              ShimmerRowCard(
                leading: const ShimmerCircle(size: StopNumber.size),
                titleFactor: [0.6, 0.45, 0.52][i],
                subtitleFactor: [0.4, 0.3, 0.36][i],
              ),
            ],
          ],
        ),
      );
}
