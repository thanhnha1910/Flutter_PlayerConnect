import 'package:injectable/injectable.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';
import '../datasources/notification_remote_datasource.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  
  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  }) {
    return _remoteDataSource.getNotifications(
      page: page,
      limit: limit,
      type: type,
      isRead: isRead,
    );
  }

  @override
  Future<int> getUnreadCount() {
    return _remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(int notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(int notificationId) {
    return _remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> sendTestNotification() {
    return _remoteDataSource.sendTestNotification();
  }

  @override
  Stream<NotificationModel> get notificationStream => _remoteDataSource.notificationStream;

  @override
  Stream<int> get unreadCountStream => _remoteDataSource.unreadCountStream;

  @override
  Future<void> initializeSocket() {
    return _remoteDataSource.initializeSocket();
  }

  @override
  Future<void> disconnectSocket() {
    return _remoteDataSource.disconnectSocket();
  }
}