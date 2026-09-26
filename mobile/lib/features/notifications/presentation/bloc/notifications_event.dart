abstract class NotificationsEvent {}

class NotificationsLoadEvent extends NotificationsEvent {}

class NotificationsLoadMoreEvent extends NotificationsEvent {}

class NotificationsMarkReadEvent extends NotificationsEvent {
  final int id;
  NotificationsMarkReadEvent(this.id);
}

class NotificationsMarkAllReadEvent extends NotificationsEvent {}
