import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int page;
  final int limit;
  final bool? isRead;

  const LoadNotifications({
    this.page = 1,
    this.limit = 20,
    this.isRead,
  });

  @override
  List<Object?> get props => [page, limit, isRead];
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends NotificationEvent {
  final int notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class LoadUnreadCount extends NotificationEvent {
  const LoadUnreadCount();
}

class InitializeNotificationSocket extends NotificationEvent {
  const InitializeNotificationSocket();
}

class NewNotificationReceived extends NotificationEvent {
  final Map<String, dynamic> notificationData;

  const NewNotificationReceived(this.notificationData);

  @override
  List<Object> get props => [notificationData];
}

class SendTestNotification extends NotificationEvent {
  const SendTestNotification();
}

class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}

class FilterNotifications extends NotificationEvent {
  final bool? isRead;
  final String? type;

  const FilterNotifications({
    this.isRead,
    this.type,
  });

  @override
  List<Object?> get props => [isRead, type];
}