import 'package:equatable/equatable.dart';
import '../../../data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoadingMore extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoadingMore({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object> get props => [notifications, unreadCount];
}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool hasReachedMax;
  final int currentPage;
  final bool? currentFilter;
  final String? currentTypeFilter;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.currentFilter,
    this.currentTypeFilter,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? hasReachedMax,
    int? currentPage,
    bool? currentFilter,
    String? currentTypeFilter,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
      currentTypeFilter: currentTypeFilter ?? this.currentTypeFilter,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        hasReachedMax,
        currentPage,
        currentFilter,
        currentTypeFilter,
      ];
}

class NotificationError extends NotificationState {
  final String message;
  final List<NotificationModel>? notifications;
  final int? unreadCount;

  const NotificationError({
    required this.message,
    this.notifications,
    this.unreadCount,
  });

  @override
  List<Object?> get props => [message, notifications, unreadCount];
}

class NotificationActionLoading extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String actionType; // 'marking_read', 'deleting', 'marking_all_read'

  const NotificationActionLoading({
    required this.notifications,
    required this.unreadCount,
    required this.actionType,
  });

  @override
  List<Object> get props => [notifications, unreadCount, actionType];
}

class NotificationActionSuccess extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String message;

  const NotificationActionSuccess({
    required this.notifications,
    required this.unreadCount,
    required this.message,
  });

  @override
  List<Object> get props => [notifications, unreadCount, message];
}

class NotificationActionError extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String message;

  const NotificationActionError({
    required this.notifications,
    required this.unreadCount,
    required this.message,
  });

  @override
  List<Object> get props => [notifications, unreadCount, message];
}

class NotificationSocketConnected extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationSocketConnected({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object> get props => [notifications, unreadCount];
}

class NotificationSocketDisconnected extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationSocketDisconnected({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object> get props => [notifications, unreadCount];
}

class NewNotificationReceived extends NotificationState {
  final NotificationModel newNotification;
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NewNotificationReceived({
    required this.newNotification,
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object> get props => [newNotification, notifications, unreadCount];
}