import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../models/notification_model.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/services/websocket_service.dart';

abstract class NotificationRemoteDataSource {
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

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final WebSocketService _webSocketService;

  // WebSocket streams
  final StreamController<List<NotificationModel>> _notificationController =
      StreamController<List<NotificationModel>>.broadcast();
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  NotificationRemoteDataSourceImpl({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
    required WebSocketService webSocketService,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage,
       _webSocketService = webSocketService {
    _setupWebSocketListeners();
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? isRead,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
        if (isRead != null) 'isRead': isRead.toString(),
      };

      final response = await _apiClient.dio.get(
        '/user/notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Handle both direct array and wrapped response
        final dynamic responseData = response.data;
        final List<dynamic> data;

        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          data = responseData['data'] ?? responseData['content'] ?? [];
        } else {
          data = [];
        }

        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }

      throw Exception('Failed to load notifications');
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(
        '/user/notifications/unread-count',
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        if (responseData is int) {
          return responseData;
        } else if (responseData is Map<String, dynamic>) {
          return responseData['unreadCount'] ?? 0;
        }

        return 0;
      }

      throw Exception('Failed to load unread count');
    } catch (e) {
      throw Exception('Error loading unread count: $e');
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.dio.put(
        '/user/notifications/$notificationId/read',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.put('/user/notifications/read-all');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/user/notifications/$notificationId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  @override
  Future<void> sendTestNotification() async {
    try {
      final userData = await _secureStorage.getUserData();
      final userId = userData?['id'];

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _apiClient.dio.post(
        '/user/notifications/test',
        data: {'userId': userId, 'message': 'This is a test notification'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send test notification');
      }
    } catch (e) {
      throw Exception('Error sending test notification: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> get notificationStream =>
      _notificationController.stream;

  @override
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  void _setupWebSocketListeners() {
    // Listen to general notifications
    _webSocketService.notificationStream.listen((notificationData) {
      _handleNewNotification(notificationData);
    });

    // Note: Unread count will be calculated from notifications list
  }

  void _handleNewNotification(Map<String, dynamic> notificationData) {
    try {
      // Convert the notification data to NotificationModel
      final notification = NotificationModel.fromJson(notificationData);

      // Refresh notifications list when new notification arrives
      getNotifications()
          .then((notifications) {
            _notificationController.add(notifications);
          })
          .catchError((error) {
            print('Error refreshing notifications: $error');
          });
    } catch (e) {
      print('Error parsing notification data: $e');
    }
  }

  @override
  Future<void> initializeSocket() async {
    try {
      await _webSocketService.connect();
      print('WebSocket connection initialized successfully');
    } catch (e) {
      print('Error initializing WebSocket: $e');
    }
  }

  @override
  Future<void> disconnectSocket() async {
    try {
      await _webSocketService.disconnect();
      print('WebSocket disconnected successfully');
    } catch (e) {
      print('Error disconnecting WebSocket: $e');
    }
  }

  void dispose() {
    _webSocketService.disconnect();
    _notificationController.close();
    _unreadCountController.close();
  }
}
