import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/notification_model.dart';
import '../../../domain/repositories/notification_repository.dart';
import 'notification_event.dart' as events;
import 'notification_state.dart' as states;

@injectable
class NotificationBloc extends Bloc<events.NotificationEvent, states.NotificationState> {
  final NotificationRepository _notificationRepository;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _unreadCountSubscription;
  
  static const int _pageSize = 20;
  
  NotificationBloc(this._notificationRepository) : super(const states.NotificationInitial()) {
    on<events.LoadNotifications>(_onLoadNotifications);
    on<events.RefreshNotifications>(_onRefreshNotifications);
    on<events.LoadMoreNotifications>(_onLoadMoreNotifications);
    on<events.MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<events.MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<events.DeleteNotification>(_onDeleteNotification);
    on<events.LoadUnreadCount>(_onLoadUnreadCount);
    on<events.InitializeNotificationSocket>(_onInitializeNotificationSocket);
    on<events.NewNotificationReceived>(_onNewNotificationReceived);
    on<events.SendTestNotification>(_onSendTestNotification);
    on<events.FilterNotifications>(_onFilterNotifications);
    
    // Listen to real-time notifications
    _setupNotificationListeners();
  }
  
  void _setupNotificationListeners() {
    _notificationSubscription = _notificationRepository.notificationStream.listen(
      (notifications) {
        // Handle list of notifications from WebSocket
        for (final notification in notifications) {
          add(events.NewNotificationReceived(notification.toJson()));
        }
      },
      onError: (error) {
        print('Error in notification stream: $error');
      },
    );
    
    _unreadCountSubscription = _notificationRepository.unreadCountStream.listen(
      (count) {
        add(const events.LoadUnreadCount());
      },
      onError: (error) {
        print('Error in unread count stream: $error');
      },
    );
  }
  
  Future<void> _onLoadNotifications(
    events.LoadNotifications event,
    Emitter<states.NotificationState> emit,
  ) async {
    try {
      emit(const states.NotificationLoading());
      
      final notifications = await _notificationRepository.getNotifications(
        page: event.page,
        limit: event.limit,
        isRead: event.isRead,
      );
      
      final unreadCount = await _notificationRepository.getUnreadCount();
      
      emit(states.NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasReachedMax: notifications.length < event.limit,
        currentPage: event.page,
        currentFilter: event.isRead,
      ));
    } catch (e) {
      emit(states.NotificationError(message: e.toString()));
    }
  }
  
  Future<void> _onRefreshNotifications(
    events.RefreshNotifications event,
    Emitter<states.NotificationState> emit,
  ) async {
    try {
      final currentState = state;
      bool? currentFilter;
      String? currentTypeFilter;
      
      if (currentState is states.NotificationLoaded) {
        currentFilter = currentState.currentFilter;
        currentTypeFilter = currentState.currentTypeFilter;
      }
      
      final notifications = await _notificationRepository.getNotifications(
        page: 1,
        limit: _pageSize,
        isRead: currentFilter,
      );
      
      final unreadCount = await _notificationRepository.getUnreadCount();
      
      emit(states.NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasReachedMax: notifications.length < _pageSize,
        currentPage: 1,
        currentFilter: currentFilter,
        currentTypeFilter: currentTypeFilter,
      ));
    } catch (e) {
      if (state is states.NotificationLoaded) {
        final currentState = state as states.NotificationLoaded;
        emit(states.NotificationError(
          message: e.toString(),
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
        ));
      } else {
        emit(states.NotificationError(message: e.toString()));
      }
    }
  }
  
  Future<void> _onLoadMoreNotifications(
    events.LoadMoreNotifications event,
    Emitter<states.NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.NotificationLoaded || currentState.hasReachedMax) {
      return;
    }
    
    try {
      emit(states.NotificationLoadingMore(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
      ));
      
      final nextPage = currentState.currentPage + 1;
      final newNotifications = await _notificationRepository.getNotifications(
        page: nextPage,
        limit: _pageSize,
        isRead: currentState.currentFilter,
      );
      
      final allNotifications = [...currentState.notifications, ...newNotifications];
      
      emit(states.NotificationLoaded(
        notifications: allNotifications,
        unreadCount: currentState.unreadCount,
        hasReachedMax: newNotifications.length < _pageSize,
        currentPage: nextPage,
        currentFilter: currentState.currentFilter,
        currentTypeFilter: currentState.currentTypeFilter,
      ));
    } catch (e) {
      emit(states.NotificationActionError(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        message: 'Không thể tải thêm thông báo: ${e.toString()}',
      ));
    }
  }
  
  Future<void> _onMarkNotificationAsRead(
    events.MarkNotificationAsRead event,
    Emitter<states.NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.NotificationLoaded) return;
    
    try {
      emit(states.NotificationActionLoading(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        actionType: 'marking_read',
      ));
      
      await _notificationRepository.markAsRead(event.notificationId);
      
      // Mark as read successful
      // Update the notification in the list
      final updatedNotifications = currentState.notifications.map((notification) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }
        return notification;
      }).toList();
      
      final newUnreadCount = await _notificationRepository.getUnreadCount();
      
      emit(states.NotificationActionSuccess(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        message: 'Đã đánh dấu thông báo là đã đọc',
      ));
      
      // Return to loaded state
      emit(states.NotificationLoaded(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        currentFilter: currentState.currentFilter,
        currentTypeFilter: currentState.currentTypeFilter,
      ));
    } catch (e) {
      emit(states.NotificationActionError(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        message: 'Lỗi khi đánh dấu thông báo: ${e.toString()}',
      ));
    }
  }
  
  Future<void> _onMarkAllNotificationsAsRead(
    events.MarkAllNotificationsAsRead event,
    Emitter<states.NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.NotificationLoaded) return;
    
    try {
      emit(states.NotificationActionLoading(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        actionType: 'marking_all_read',
      ));
      
      await _notificationRepository.markAllAsRead();
      
      // Mark all as read successful
      // Update all notifications to read
      final updatedNotifications = currentState.notifications.map((notification) {
        return notification.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();
      
      emit(states.NotificationActionSuccess(
        notifications: updatedNotifications,
        unreadCount: 0,
        message: 'Đã đánh dấu tất cả thông báo là đã đọc',
      ));
      
      // Return to loaded state
      emit(states.NotificationLoaded(
        notifications: updatedNotifications,
        unreadCount: 0,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        currentFilter: currentState.currentFilter,
        currentTypeFilter: currentState.currentTypeFilter,
      ));
    } catch (e) {
      emit(states.NotificationActionError(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        message: 'Lỗi khi đánh dấu tất cả thông báo: ${e.toString()}',
      ));
    }
  }
  
  Future<void> _onDeleteNotification(
    events.DeleteNotification event,
    Emitter<states.NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! states.NotificationLoaded) return;
    
    try {
      emit(states.NotificationActionLoading(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        actionType: 'deleting',
      ));
      
      await _notificationRepository.deleteNotification(event.notificationId);
      
      // Delete successful
      // Remove the notification from the list
      final updatedNotifications = currentState.notifications
          .where((notification) => notification.id != event.notificationId)
          .toList();
      
      final newUnreadCount = await _notificationRepository.getUnreadCount();
      
      emit(states.NotificationActionSuccess(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        message: 'Đã xóa thông báo',
      ));
      
      // Return to loaded state
      emit(states.NotificationLoaded(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        currentFilter: currentState.currentFilter,
        currentTypeFilter: currentState.currentTypeFilter,
      ));
    } catch (e) {
      emit(states.NotificationActionError(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        message: 'Lỗi khi xóa thông báo: ${e.toString()}',
      ));
    }
  }
  
  Future<void> _onLoadUnreadCount(
    events.LoadUnreadCount event,
    Emitter<states.NotificationState> emit,
  ) async {
    try {
      final unreadCount = await _notificationRepository.getUnreadCount();
      
      if (state is states.NotificationLoaded) {
        final currentState = state as states.NotificationLoaded;
        emit(currentState.copyWith(unreadCount: unreadCount));
      }
    } catch (e) {
      // Silently handle error for unread count
      print('Error loading unread count: $e');
    }
  }
  
  Future<void> _onInitializeNotificationSocket(
    events.InitializeNotificationSocket event,
    Emitter<states.NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.initializeSocket();
      
      if (state is states.NotificationLoaded) {
        final currentState = state as states.NotificationLoaded;
        emit(states.NotificationSocketConnected(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
        ));
      }
    } catch (e) {
      print('Error initializing notification socket: $e');
    }
  }
  
  Future<void> _onNewNotificationReceived(
    events.NewNotificationReceived event,
    Emitter<states.NotificationState> emit,
  ) async {
    try {
      final notification = NotificationModel.fromJson(event.notificationData);
      
      if (state is states.NotificationLoaded) {
        final currentState = state as states.NotificationLoaded;
        final updatedNotifications = [notification, ...currentState.notifications];
        final newUnreadCount = currentState.unreadCount + (notification.isRead ? 0 : 1);
        
        emit(states.NewNotificationReceived(
          newNotification: notification,
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        ));
        
        // Return to loaded state with updated data
        emit(states.NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          currentFilter: currentState.currentFilter,
          currentTypeFilter: currentState.currentTypeFilter,
        ));
      }
    } catch (e) {
      print('Error processing new notification: $e');
    }
  }
  
  Future<void> _onSendTestNotification(
    events.SendTestNotification event,
    Emitter<states.NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.sendTestNotification();
      
      if (state is states.NotificationLoaded) {
        final currentState = state as states.NotificationLoaded;
        emit(states.NotificationActionSuccess(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: 'Đã gửi thông báo test thành công',
        ));
        
        // Refresh notifications to show the new test notification
        add(const events.RefreshNotifications());
      }
    } catch (e) {
      if (state is states.NotificationLoaded) {
        final currentState = state as states.NotificationLoaded;
        emit(states.NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: 'Không thể gửi thông báo test: ${e.toString()}',
        ));
      }
    }
  }
  
  Future<void> _onFilterNotifications(
    events.FilterNotifications event,
    Emitter<states.NotificationState> emit,
  ) async {
    try {
      emit(const states.NotificationLoading());
      
      final notifications = await _notificationRepository.getNotifications(
        page: 1,
        limit: _pageSize,
        isRead: event.isRead,
      );
      
      final unreadCount = await _notificationRepository.getUnreadCount();
      
      emit(states.NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasReachedMax: notifications.length < _pageSize,
        currentPage: 1,
        currentFilter: event.isRead,
        currentTypeFilter: event.type,
      ));
    } catch (e) {
      emit(states.NotificationError(message: e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _notificationRepository.disconnectSocket();
    return super.close();
  }
}