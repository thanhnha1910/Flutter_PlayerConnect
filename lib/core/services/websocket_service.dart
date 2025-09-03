import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../storage/secure_storage.dart';

@injectable
class WebSocketService {
  final SecureStorage _secureStorage;
  
  StompClient? _stompClient;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  final StreamController<Map<String, dynamic>> _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _draftMatchController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _matchController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _invitationController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Subscription management
  final Map<String, Function()> _subscriptions = {};
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  WebSocketService(this._secureStorage);
  
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get draftMatchStream => _draftMatchController.stream;
  Stream<Map<String, dynamic>> get matchStream => _matchController.stream;
  Stream<Map<String, dynamic>> get invitationStream => _invitationController.stream;
  
  bool get isConnected => _isConnected;
  
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      print('WebSocket already connected or connecting');
      return;
    }
    
    try {
      _isConnecting = true;
      
      final userData = await _secureStorage.getUserData();
      final token = await _secureStorage.getToken();
      
      if (userData == null || token == null) {
        throw Exception('User not authenticated');
      }
      
      _stompClient = StompClient(
        config: StompConfig(
          url: 'ws://localhost:1444/ws',
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          onWebSocketDone: _onWebSocketDone,
          beforeConnect: () async {
            print('🔌 Connecting to WebSocket...');
          },
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
            'heart-beat': '10000,10000',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          connectionTimeout: const Duration(seconds: 10),
        ),
      );
      
      _stompClient!.activate();
      
    } catch (e) {
      _isConnecting = false;
      print('❌ WebSocket connection error: $e');
      _scheduleReconnect();
    }
  }
  
  void _onConnect(StompFrame frame) {
    print('✅ WebSocket connected successfully');
    _isConnected = true;
    _isConnecting = false;
    _cancelReconnectTimer();
    
    // Subscribe to user notifications
    _subscribeToUserNotifications();
    
    // Start heartbeat
    _startHeartbeat();
  }
  
  void _onDisconnect(StompFrame frame) {
    print('🔌 WebSocket disconnected');
    _isConnected = false;
    _isConnecting = false;
    _clearSubscriptions();
    _stopHeartbeat();
    _scheduleReconnect();
  }
  
  void _onStompError(StompFrame frame) {
    print('❌ STOMP Error: ${frame.body}');
    _isConnected = false;
    _isConnecting = false;
    _scheduleReconnect();
  }
  
  void _onWebSocketError(dynamic error) {
    print('❌ WebSocket Error: $error');
    _isConnected = false;
    _isConnecting = false;
    _scheduleReconnect();
  }
  
  void _onWebSocketDone() {
    print('🔌 WebSocket connection closed');
    _isConnected = false;
    _isConnecting = false;
    _scheduleReconnect();
  }
  
  Future<void> _subscribeToUserNotifications() async {
    final userData = await _secureStorage.getUserData();
    final userId = userData?['id'];
    
    if (userId == null) {
      print('❌ Cannot subscribe: User ID not found');
      return;
    }
    
    // Subscribe to user notifications
    final notificationSub = _stompClient!.subscribe(
      destination: '/user/$userId/queue/notifications',
      callback: _handleNotificationMessage,
    );
    _subscriptions['notifications'] = notificationSub;
    
    print('📱 Subscribed to user notifications for user: $userId');
  }
  
  void _handleNotificationMessage(StompFrame frame) {
    try {
      print('🔥 RAW WEBSOCKET MESSAGE RECEIVED: ${frame.body}');
      
      final notification = json.decode(frame.body!);
      print('🔥 PARSED MESSAGE OBJECT: $notification');
      print('🔥 MESSAGE TYPE: ${notification['type']}');
      print('🔥 MESSAGE TITLE: ${notification['title']}');
      print('🔥 MESSAGE CONTENT: ${notification['content']}');
      
      final notificationType = notification['type'] as String?;
      
      // Handle different notification types
      switch (notificationType) {
        case 'DRAFT_MATCH_INTEREST':
        case 'DRAFT_MATCH_UPDATED':
        case 'DRAFT_MATCH_CONFIRMED':
        case 'DRAFT_MATCH_ACCEPTED':
        case 'DRAFT_MATCH_REJECTED':
        case 'DRAFT_MATCH_WITHDRAW':
        case 'DRAFT_MATCH_CONVERTED':
        case 'DRAFT_MATCH_USER_ACTION':
          _handleDraftMatchNotification(notification);
          break;
          
        case 'INVITATION':
        case 'INVITATION_ACCEPTED':
        case 'INVITATION_REJECTED':
        case 'MATCH_JOINED':
        case 'MATCH_LEFT':
          _handleGeneralNotification(notification);
          break;
          
        case 'ACTION_SUCCESS':
        case 'POSITIVE_ALERT':
        case 'INFO_UPDATE':
        case 'ERROR_ALERT':
        case 'WARNING_ALERT':
          _handleToastNotification(notification);
          break;
          
        default:
          _handleGeneralNotification(notification);
          break;
      }
      
    } catch (e) {
      print('❌ Error parsing notification message: $e');
    }
  }
  
  void _handleDraftMatchNotification(Map<String, dynamic> notification) {
    // Add to notification stream
    _notificationController.add(notification);
    
    // Also add to draft match specific stream for real-time updates
    _draftMatchController.add(notification);
    
    // Add to invitation stream for InvitationScreen to receive updates
    _invitationController.add(notification);
    
    print('📱 Draft match notification processed: ${notification['type']}');
  }
  
  void _handleGeneralNotification(Map<String, dynamic> notification) {
    _notificationController.add(notification);
    
    print('📱 General notification processed: ${notification['type']}');
  }
  
  void _handleToastNotification(Map<String, dynamic> notification) {
    // For toast notifications, we might want to show them immediately
    // without adding to the persistent notification list
    print('🍞 Toast notification: ${notification['title']} - ${notification['content']}');
    
    // Still add to notification stream for consistency
    _notificationController.add(notification);
  }
  
  Future<void> subscribeToDraftMatch(String draftMatchId) async {
    if (!_isConnected || _stompClient == null) {
      print('❌ Cannot subscribe to draft match: WebSocket not connected');
      return;
    }
    
    final subscriptionKey = 'draft_match_$draftMatchId';
    
    // Unsubscribe if already subscribed
    if (_subscriptions.containsKey(subscriptionKey)) {
      _subscriptions[subscriptionKey]?.call();
    }
    
    // Subscribe to draft match updates
    final subscription = _stompClient!.subscribe(
      destination: '/topic/draft-match/$draftMatchId',
      callback: (frame) {
        try {
          final update = json.decode(frame.body!);
          _draftMatchController.add(update);
          print('📱 Draft match update received for: $draftMatchId');
        } catch (e) {
          print('❌ Error parsing draft match update: $e');
        }
      },
    );
    
    _subscriptions[subscriptionKey] = subscription;
    print('📱 Subscribed to draft match updates: $draftMatchId');
  }
  
  Future<void> subscribeToDraftMatchInterest() async {
    if (!_isConnected || _stompClient == null) {
      print('❌ Cannot subscribe to draft match interest: WebSocket not connected');
      return;
    }
    
    const subscriptionKey = 'draft_match_interest';
    
    // Unsubscribe if already subscribed
    if (_subscriptions.containsKey(subscriptionKey)) {
      _subscriptions[subscriptionKey]?.call();
    }
    
    // Subscribe to draft match interest updates
    final subscription = _stompClient!.subscribe(
      destination: '/topic/draft-match-interest',
      callback: (frame) {
        try {
          final update = json.decode(frame.body!);
          _draftMatchController.add(update);
          print('📱 Draft match interest update received');
        } catch (e) {
          print('❌ Error parsing draft match interest update: $e');
        }
      },
    );
    
    _subscriptions[subscriptionKey] = subscription;
    print('📱 Subscribed to draft match interest updates');
  }
  
  void unsubscribeFromDraftMatch(String draftMatchId) {
    final subscriptionKey = 'draft_match_$draftMatchId';
    if (_subscriptions.containsKey(subscriptionKey)) {
      _subscriptions[subscriptionKey]?.call();
      _subscriptions.remove(subscriptionKey);
      print('📱 Unsubscribed from draft match: $draftMatchId');
    }
  }
  
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _stompClient != null) {
        _stompClient!.send(
          destination: '/app/heartbeat',
          body: json.encode({'timestamp': DateTime.now().millisecondsSinceEpoch}),
        );
      }
    });
  }
  
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
  
  void _scheduleReconnect() {
    _cancelReconnectTimer();
    
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isConnecting) {
        print('🔄 Attempting to reconnect WebSocket...');
        connect();
      }
    });
  }
  
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  void _clearSubscriptions() {
    for (final unsubscribe in _subscriptions.values) {
      unsubscribe();
    }
    _subscriptions.clear();
  }
  
  Future<void> disconnect() async {
    print('🔌 Disconnecting WebSocket...');
    
    _cancelReconnectTimer();
    _stopHeartbeat();
    _clearSubscriptions();
    
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    
    _isConnected = false;
    _isConnecting = false;
  }
  
  void dispose() {
    disconnect();
    _notificationController.close();
    _draftMatchController.close();
    _matchController.close();
    _invitationController.close();
  }
}