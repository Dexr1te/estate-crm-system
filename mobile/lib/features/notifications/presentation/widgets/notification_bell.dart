import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/notifications/presentation/bloc/unread_count_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _count = UnreadCountBloc(Injector.notificationsRepository);

  @override
  void initState() {
    super.initState();
    _count.add(UnreadCountRefreshEvent());
  }

  @override
  void dispose() {
    _count.close();
    super.dispose();
  }

  Future<void> _open() async {
    await context.push('/notifications');
    if (mounted) _count.add(UnreadCountRefreshEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<UnreadCountBloc, int>(
      bloc: _count,
      builder: (context, count) => Semantics(
        button: true,
        label:
            '${l10n.notificationsTitle}. ${l10n.notificationsUnreadLabel(count)}',
        excludeSemantics: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppIconTile(
              icon: count > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              tooltip: l10n.notificationsTitle,
              onPressed: _open,
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 2,
                child: IgnorePointer(child: UnreadBadge(count: count)),
              ),
          ],
        ),
      ),
    );
  }
}

class UnreadBadge extends StatelessWidget {
  final int count;

  const UnreadBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      key: const ValueKey('notifications-unread-badge'),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.dangerSolid,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: t.background, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textScaler: TextScaler.noScaling,
        style: const TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 10.5,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
