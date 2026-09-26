import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsError extends NotificationsState {
  final ApiFailure failure;
  NotificationsError(this.failure);
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  NotificationsLoaded(
    this.items, {
    this.page = 0,
    this.hasMore = false,
    this.loadingMore = false,
  });

  bool get hasUnread => items.any((n) => !n.isRead);

  NotificationsLoaded copyWith({
    List<AppNotification>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      NotificationsLoaded(
        items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class NotificationsActionSuccess extends NotificationsLoaded
    with ActionSucceeded {
  @override
  final ActionMessage message;

  NotificationsActionSuccess(this.message, NotificationsLoaded from)
      : super(from.items, page: from.page, hasMore: from.hasMore);
}

class NotificationsActionFailure extends NotificationsLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  NotificationsActionFailure(this.failure, NotificationsLoaded from)
      : super(from.items, page: from.page, hasMore: from.hasMore);
}
