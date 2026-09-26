import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class NotificationCopy {
  final String title;
  final String? detail;
  final IconData icon;

  const NotificationCopy(this.title, this.detail, this.icon);
}

class NotificationTarget {
  final String location;
  final bool push;

  const NotificationTarget(this.location, {this.push = true});
}

NotificationCopy notificationCopy(AppLocalizations l10n, AppNotification n) {
  String name(String key) {
    final value = n.text(key);
    return value == null || value.trim().isEmpty
        ? l10n.notificationsSomeone
        : value;
  }

  String plain(String key) => n.text(key) ?? '';

  switch (n.type) {
    case NotificationType.taskAssigned:
      return NotificationCopy(
          l10n.notificationsTaskAssigned(name('actorName'), plain('taskTitle')),
          null,
          Icons.task_alt_rounded);
    case NotificationType.recordsHandedOver:
      final parts = <String>[
        if (n.count('clients') > 0)
          l10n.notificationsCountClients(n.count('clients')),
        if (n.count('properties') > 0)
          l10n.notificationsCountListings(n.count('properties')),
        if (n.count('deals') > 0)
          l10n.notificationsCountDeals(n.count('deals')),
        if (n.count('meetings') > 0)
          l10n.notificationsCountMeetings(n.count('meetings')),
        if (n.count('tasks') > 0)
          l10n.notificationsCountTasks(n.count('tasks')),
      ];
      final total = n.count('clients') +
          n.count('properties') +
          n.count('deals') +
          n.count('meetings') +
          n.count('tasks');
      return NotificationCopy(
          l10n.notificationsHandedOver(total, name('fromName')),
          parts.isEmpty ? null : parts.join(', '),
          Icons.swap_horiz_rounded);
    case NotificationType.joinRequest:
      return NotificationCopy(
          l10n.notificationsJoinRequest(name('actorName'), plain('teamName')),
          null,
          Icons.group_add_outlined);
    case NotificationType.joinAccepted:
      return NotificationCopy(
          l10n.notificationsJoinAccepted(name('agentName'), plain('teamName')),
          null,
          Icons.how_to_reg_outlined);
    case NotificationType.newMatch:
      return NotificationCopy(
          l10n.notificationsNewMatch(plain('propertyTitle')),
          _buyers(l10n, n),
          Icons.home_work_outlined);
    case NotificationType.priceDropMatch:
      return NotificationCopy(
          l10n.notificationsPriceDrop(_price(n, 'oldPrice'),
              _price(n, 'newPrice'), plain('propertyTitle')),
          _buyers(l10n, n),
          Icons.trending_down_rounded);
    case NotificationType.dealStatusChanged:
      final to = DealStatus.values
          .where((s) => s.name == n.text('toStatus'))
          .firstOrNull;
      return NotificationCopy(
          l10n.notificationsDealStatus(name('actorName'),
              to == null ? '' : dealStatusLabel(l10n, to), plain('dealTitle')),
          null,
          Icons.handshake_outlined);
    case NotificationType.unknown:
      return NotificationCopy(
          l10n.notificationsUnknown, null, Icons.notifications_none_rounded);
  }
}

String _price(AppNotification n, String key) {
  final amount = n.amount(key);
  return amount == null ? '' : formatPrice(amount);
}

String? _buyers(AppLocalizations l10n, AppNotification n) {
  final names = n.names('buyerNames');
  final count = n.count('buyerCount');
  if (names.isEmpty || count == 0) return null;
  final listed = names.join(', ');
  final more = count - names.length;
  return l10n.notificationsFitsBuyers(
      count, more > 0 ? l10n.notificationsMoreNames(more, listed) : listed);
}

NotificationTarget? notificationTarget(AppNotification n) {
  final id = n.targetId;
  switch (n.type) {
    case NotificationType.taskAssigned:
      return const NotificationTarget('/tasks');
    case NotificationType.recordsHandedOver:
      if (n.count('clients') > 0) {
        return const NotificationTarget('/clients', push: false);
      }
      if (n.count('deals') > 0) {
        return const NotificationTarget('/deals', push: false);
      }
      if (n.count('properties') > 0) {
        return const NotificationTarget('/properties', push: false);
      }
      if (n.count('tasks') > 0) return const NotificationTarget('/tasks');
      return const NotificationTarget('/meetings', push: false);
    case NotificationType.joinRequest:
      return const NotificationTarget('/onboarding/waiting', push: false);
    case NotificationType.joinAccepted:
      return const NotificationTarget('/team-console', push: false);
    case NotificationType.newMatch:
    case NotificationType.priceDropMatch:
      return id == null ? null : NotificationTarget('/properties/$id');
    case NotificationType.dealStatusChanged:
      return id == null ? null : NotificationTarget('/deals/$id');
    case NotificationType.unknown:
      return null;
  }
}
