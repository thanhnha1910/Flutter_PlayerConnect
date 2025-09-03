import '../../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  });
  
  Future<int> getUnreadCount();
  
  Future<void> markAsRead(int notificationId);
  
  Future<void> markAllAsRead();
  
  Future<void> deleteNotification(int notificationId);
  
  Future<void> sendTestNotification();
  
  Stream<List<NotificationModel>> get notificationStream;
  
  Stream<int> get unreadCountStream;
  
  Future<void> initializeSocket();
  
  Future<void> disconnectSocket();
}