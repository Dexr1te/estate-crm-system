import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class NotificationRow extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationRow({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final copy = notificationCopy(l10n, notification);
    final unread = !notification.isRead;
    final at = notification.createdAt.toLocal();

    return AppCard(
      key: ValueKey('notification-${notification.id}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      borderColor: unread ? t.primary.withValues(alpha: 0.35) : null,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: t.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(copy.icon,
                size: 17, color: unread ? t.textPrimary : t.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                    color: unread ? t.textPrimary : t.textSecondary,
                  ),
                ),
                if (copy.detail != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    copy.detail!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        color: t.textSecondary),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _isToday(at)
                      ? formatTimeOfDay(at)
                      : '${formatDayMonth(at, locale)}, ${formatTimeOfDay(at)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      color: t.textHint),
                ),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                key: const ValueKey('notification-unread-dot'),
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: t.dangerSolid, shape: BoxShape.circle),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

bool _isToday(DateTime at) {
  final now = AppClock.now();
  return at.year == now.year && at.month == now.month && at.day == now.day;
}

bool isNotificationFromToday(AppNotification n) =>
    _isToday(n.createdAt.toLocal());
