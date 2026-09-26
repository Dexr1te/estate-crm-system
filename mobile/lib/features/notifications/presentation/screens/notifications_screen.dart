import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:real_estate_crm/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:real_estate_crm/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_copy.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _bloc = NotificationsBloc(Injector.notificationsRepository)
    ..add(NotificationsLoadEvent());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _open(AppNotification n) {
    if (!n.isRead) _bloc.add(NotificationsMarkReadEvent(n.id));
    final target = notificationTarget(n);
    if (target == null) return;
    if (target.push) {
      context.push(target.location);
    } else {
      context.go(target.location);
    }
  }

  bool _nearEnd(ScrollNotification s) {
    if (s.metrics.axis == Axis.vertical && s.metrics.extentAfter < 400) {
      _bloc.add(NotificationsLoadMoreEvent());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      bloc: _bloc,
      listener: showActionOutcome,
      builder: (context, state) => NotificationListener<ScrollNotification>(
        onNotification: _nearEnd,
        child: DetailScaffold(
          title: l10n.notificationsTitle,
          actions: [
            if (state is NotificationsLoaded && state.hasUnread)
              AppIconTile(
                key: const ValueKey('notifications-mark-all'),
                icon: Icons.done_all_rounded,
                tooltip: l10n.notificationsMarkAllRead,
                onPressed: () => _bloc.add(NotificationsMarkAllReadEvent()),
              ),
          ],
          onRefresh: () async => _bloc.add(NotificationsLoadEvent()),
          children: _body(state, l10n),
        ),
      ),
    );
  }

  List<Widget> _body(NotificationsState state, AppLocalizations l10n) {
    if (state is NotificationsError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.notificationsTitle,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(NotificationsLoadEvent())),
        ),
      ];
    }
    if (state is! NotificationsLoaded) {
      return [for (var i = 0; i < 5; i++) const _RowBone()];
    }
    if (state.items.isEmpty) {
      return [
        EmptyState(
          icon: Icons.notifications_none_rounded,
          title: l10n.notificationsEmptyTitle,
          subtitle: l10n.notificationsEmptyBody,
        ),
      ];
    }
    final today = state.items.where(isNotificationFromToday).toList();
    final earlier =
        state.items.where((n) => !isNotificationFromToday(n)).toList();
    return [
      if (today.isNotEmpty) ...[
        SectionHeader(title: l10n.notificationsToday),
        for (final n in today)
          NotificationRow(notification: n, onTap: () => _open(n)),
      ],
      if (earlier.isNotEmpty) ...[
        SectionHeader(title: l10n.notificationsEarlier),
        for (final n in earlier)
          NotificationRow(notification: n, onTap: () => _open(n)),
      ],
      if (state.loadingMore) const _RowBone(),
    ];
  }
}

class _RowBone extends StatelessWidget {
  const _RowBone();

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 34, height: 34, radius: 10),
          trailing: SizedBox.shrink(),
          titleFactor: 0.7,
          subtitleFactor: 0.35,
        ),
      );
}
