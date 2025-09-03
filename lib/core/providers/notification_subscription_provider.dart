import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';

/// Provider for managing notification WebSocket subscriptions
/// Equivalent to useNotificationSubscription.js in FE
class NotificationSubscriptionProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final NotificationRepositoryImpl _notificationRepository;
  
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _unreadCountSubscription;
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  String? _currentUserId;
  
  NotificationSubscriptionProvider(
    this._webSocketService,
    this._notificationRepository,
  );

  /// Get all notifications
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  
  /// Get unread count
  int get unreadCount => _unreadCount;
  
  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Initialize notification subscription for a user
  void initializeForUser(String userId) {
    if (_currentUserId == userId) return; // Already initialized for this user
    
    _currentUserId = userId;
    _setupNotificationSubscription();
    _setupUnreadCountSubscription();
    
    debugPrint('📱 Notification subscription initialized for user: $userId');
  }

  /// Setup notification subscription
  void _setupNotificationSubscription() {
    if (_currentUserId == null) return;
    
    _notificationSubscription?.cancel();
    
    // WebSocketService automatically subscribes to user notifications when connected
    // No need to manually subscribe here
    
    _notificationSubscription = _webSocketService.notificationStream.listen(
      (notificationData) {
        try {
          debugPrint('🔥 RAW WEBSOCKET NOTIFICATION RECEIVED: $notificationData');
          
          // Handle different notification types
          final type = notificationData['type'] as String?;
          final title = notificationData['title'] as String?;
          final content = notificationData['content'] as String?;
          final relatedEntityId = notificationData['relatedEntityId']?.toString();
          final data = notificationData['data'] as Map<String, dynamic>?;
          
          debugPrint('🔥 NOTIFICATION TYPE: $type');
          debugPrint('🔥 NOTIFICATION TITLE: $title');
          debugPrint('🔥 NOTIFICATION CONTENT: $content');
          
          switch (type) {
            case 'DRAFT_MATCH_INTEREST':
              _handleDraftMatchInterestNotification(notificationData);
              break;
              
            case 'DRAFT_MATCH_UPDATED':
              _handleDraftMatchUpdatedNotification(notificationData);
              break;
              
            case 'DRAFT_MATCH_CONFIRMED':
              _handleDraftMatchConfirmedNotification(notificationData);
              break;
              
            case 'INVITATION':
              _handleInvitationNotification(notificationData);
              break;
              
            case 'INVITATION_ACCEPTED':
              _handleInvitationAcceptedNotification(notificationData);
              break;
              
            case 'INVITATION_REJECTED':
              _handleInvitationRejectedNotification(notificationData);
              break;
              
            case 'MATCH_JOINED':
              _handleMatchJoinedNotification(notificationData);
              break;
              
            case 'MATCH_LEFT':
              _handleMatchLeftNotification(notificationData);
              break;
              
            case 'DRAFT_MATCH_ACCEPTED':
              _handleDraftMatchAcceptedNotification(notificationData);
              break;
              
            case 'DRAFT_MATCH_REJECTED':
              _handleDraftMatchRejectedNotification(notificationData);
              break;
              
            case 'DRAFT_MATCH_WITHDRAW':
              _handleDraftMatchWithdrawNotification(notificationData);
              break;
              
            case 'DRAFT_MATCH_CONVERTED':
              _handleDraftMatchConvertedNotification(notificationData);
              break;
              
            case 'DRAFT_MATCH_USER_ACTION':
              _handleDraftMatchUserActionNotification(notificationData);
              break;
              
            case 'ACTION_SUCCESS':
            case 'POSITIVE_ALERT':
              debugPrint('🔥 Handling SUCCESS/POSITIVE notification');
              _handleSuccessNotification(notificationData);
              break;
              
            case 'ACTION_ERROR':
            case 'NEGATIVE_ALERT':
              _handleErrorNotification(notificationData);
              break;
              
            default:
              _handleGeneralNotification(notificationData);
              break;
          }
          
          // Refresh notifications list
          _refreshNotifications();
          
        } catch (e) {
          debugPrint('❌ Error handling notification: $e');
        }
      },
      onError: (error) {
        debugPrint('❌ Error in notification subscription: $error');
      },
    );
  }

  /// Setup unread count subscription
  void _setupUnreadCountSubscription() {
    _unreadCountSubscription?.cancel();
    
    _unreadCountSubscription = _notificationRepository.unreadCountStream.listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error in unread count subscription: $error');
      },
    );
  }

  /// Refresh notifications from repository
  void _refreshNotifications() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        // This would trigger a refresh in the notification repository
        // The actual implementation depends on your repository pattern
        debugPrint('📱 Refreshing notifications list');
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error refreshing notifications: $e');
      }
    });
  }

  // Notification handlers for different types
  void _handleDraftMatchInterestNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Có người quan tâm đến kèo của bạn!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Draft match interest notification: $title');
  }

  void _handleDraftMatchUpdatedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Kèo đã được cập nhật';
    final content = notification['content'] as String?;
    
    _showInfoToast(title, content);
    debugPrint('[DEBUG] Draft match updated notification: $title');
  }

  void _handleDraftMatchConfirmedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Kèo đã được xác nhận!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Draft match confirmed notification: $title');
  }

  void _handleInvitationNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Bạn có lời mời mới!';
    final content = notification['content'] as String?;
    
    _showInfoToast(title, content);
    debugPrint('[DEBUG] Invitation notification: $title');
  }

  void _handleInvitationAcceptedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Lời mời đã được chấp nhận!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Invitation accepted notification: $title');
  }

  void _handleInvitationRejectedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Lời mời bị từ chối';
    final content = notification['content'] as String?;
    
    _showErrorToast(title, content);
    debugPrint('[DEBUG] Invitation rejected notification: $title');
  }

  void _handleMatchJoinedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Có người tham gia trận đấu!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Match joined notification: $title');
  }

  void _handleMatchLeftNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Có người rời khỏi trận đấu';
    final content = notification['content'] as String?;
    
    _showInfoToast(title, content);
    debugPrint('[DEBUG] Match left notification: $title');
  }

  void _handleDraftMatchAcceptedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Yêu cầu đã được chấp nhận!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Draft match accepted notification: $title');
  }

  void _handleDraftMatchRejectedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Yêu cầu bị từ chối';
    final content = notification['content'] as String?;
    
    _showErrorToast(title, content);
    debugPrint('[DEBUG] Draft match rejected notification: $title');
  }

  void _handleDraftMatchWithdrawNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Có người rút khỏi kèo';
    final content = notification['content'] as String?;
    
    _showInfoToast(title, content);
    debugPrint('[DEBUG] Draft match withdraw notification: $title');
  }

  void _handleDraftMatchConvertedNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Kèo đã được chuyển thành trận đấu!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Draft match converted notification: $title');
  }

  void _handleDraftMatchUserActionNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Có hoạt động mới trong kèo!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Draft match user action notification: $title');
  }

  void _handleSuccessNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Thành công!';
    final content = notification['content'] as String?;
    
    _showSuccessToast(title, content);
    debugPrint('[DEBUG] Success notification: $title');
  }

  void _handleErrorNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Có lỗi xảy ra';
    final content = notification['content'] as String?;
    
    _showErrorToast(title, content);
    debugPrint('[DEBUG] Error notification: $title');
  }

  void _handleGeneralNotification(Map<String, dynamic> notification) {
    final title = notification['title'] as String? ?? 'Thông báo mới';
    final content = notification['content'] as String?;
    
    _showInfoToast(title, content);
    debugPrint('[DEBUG] General notification: $title');
  }

  // Toast/Snackbar methods - these would need to be implemented based on your UI framework
  void _showSuccessToast(String title, String? content) {
    // Implementation depends on your toast/snackbar system
    // For example, using ScaffoldMessenger or a toast package
    debugPrint('✅ SUCCESS: $title - $content');
  }

  void _showInfoToast(String title, String? content) {
    debugPrint('ℹ️ INFO: $title - $content');
  }

  void _showErrorToast(String title, String? content) {
    debugPrint('❌ ERROR: $title - $content');
  }

  /// Disconnect from notifications
  void disconnect() {
    _notificationSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _currentUserId = null;
    _notifications.clear();
    _unreadCount = 0;
    
    debugPrint('📱 Notification subscription disconnected');
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}