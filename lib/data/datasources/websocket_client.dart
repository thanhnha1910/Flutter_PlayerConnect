import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/chat_message_model.dart';
import '../../core/error/exceptions.dart';

@LazySingleton()
class WebSocketClient {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'ws://localhost:1444/ws';
    } else if (Platform.isAndroid) {
      return 'ws://10.0.2.2:1444/ws';
    } else if (Platform.isIOS) {
      return 'ws://localhost:1444/ws';
    }
    return 'ws://localhost:1444/ws';
  }
  
  StompClient? _stompClient;
  bool _isConnected = false;
  
  final StreamController<ChatMessageModel> _messageController = 
      StreamController<ChatMessageModel>.broadcast();
  
  final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();
  
  Stream<ChatMessageModel> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  bool get isConnected => _isConnected;
  
  Future<void> connect(String token) async {
    print('🚀 [WebSocketClient] Starting WebSocket connection...');
    print('🔗 [WebSocketClient] Target URL: $_baseUrl');
    
    if (token.isEmpty) {
      print('❌ [WebSocketClient] Empty token provided');
      throw const WebSocketAuthenticationException('Authentication token is required for WebSocket connection');
    }
    
    print('🔑 [WebSocketClient] Token provided (length: ${token.length})');
    print('🔑 [WebSocketClient] Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    
    try {
      print('⚙️ [WebSocketClient] Creating STOMP client configuration...');
      _stompClient = StompClient(
        config: StompConfig(
          url: _baseUrl,
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          connectionTimeout: const Duration(seconds: 10),
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
        ),
      );
      
      print('🔌 [WebSocketClient] Activating STOMP client...');
      _stompClient!.activate();
      print('✅ [WebSocketClient] STOMP client activation initiated');
    } catch (e) {
      print('💥 [WebSocketClient] WebSocket connection error: $e');
      _connectionController.add(false);
      throw WebSocketConnectionException('Failed to establish WebSocket connection: $e');
    }
  }
  
  void _onConnect(StompFrame frame) {
    print('WebSocket connected');
    _isConnected = true;
    _connectionController.add(true);
  }
  
  void _onDisconnect(StompFrame frame) {
    print('WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
  }
  
  void _onStompError(StompFrame frame) {
    print('STOMP error: ${frame.body}');
    _isConnected = false;
    _connectionController.add(false);
    
    // Check if it's an authentication error
    if (frame.body?.contains('401') == true || frame.body?.contains('Unauthorized') == true) {
      _connectionController.addError(const WebSocketAuthenticationException('WebSocket authentication failed - invalid or expired token'));
    } else {
      _connectionController.addError(WebSocketException('STOMP protocol error: ${frame.body}'));
    }
  }
  
  void _onWebSocketError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
    _connectionController.addError(WebSocketConnectionException('WebSocket connection error: $error'));
  }
  
  void subscribeToRoom(String roomId) {
    if (!_isConnected || _stompClient == null) {
      throw const WebSocketConnectionException('Cannot subscribe to room: WebSocket not connected');
    }
    
    try {
      _stompClient!.subscribe(
        destination: '/topic/chatrooms/$roomId',
        callback: (StompFrame frame) {
          if (frame.body != null && frame.body!.isNotEmpty) {
            try {
              print('📨 Received WebSocket message: ${frame.body}');
              final messageData = json.decode(frame.body!);
              print('📋 Parsed message data: $messageData');
              
              // Validate message data structure
              if (messageData is Map<String, dynamic>) {
                // Check for required fields and handle NULL content
                if (messageData['content'] == null || messageData['content'].toString().trim().isEmpty) {
                  print('⚠️ Received message with NULL or empty content, skipping: $messageData');
                  return; // Skip this message instead of adding it
                }
                
                // Additional validation for critical fields
                if (messageData['userId'] == null || messageData['username'] == null) {
                  print('⚠️ Received message with missing user information, skipping: $messageData');
                  return;
                }
                
                final message = ChatMessageModel.fromJson(messageData);
                print('✅ Successfully parsed message: id=${message.id}, userId=${message.userId}, username=${message.username}, content="${message.content}"');
                _messageController.add(message);
              } else {
                print('❌ Invalid message format: expected Map<String, dynamic>, got ${messageData.runtimeType}');
                _messageController.addError(WebSocketException('Invalid message format'));
              }
            } catch (e) {
              print('❌ Error parsing message: $e');
              print('📄 Raw message body: ${frame.body}');
              _messageController.addError(WebSocketException('Failed to parse incoming message: $e'));
            }
          } else {
            print('⚠️ Received empty or null WebSocket frame body, ignoring');
          }
        },
      );
    } catch (e) {
      throw WebSocketException('Failed to subscribe to room $roomId: $e');
    }
  }
  
  void unsubscribeFromRoom(String roomId) {
    if (!_isConnected || _stompClient == null) {
      return;
    }

    // Note: stomp_dart_client doesn't have unsubscribe method
    // Subscription is automatically handled when client disconnects
  }
  
  void sendMessage(String roomId, String content) {
    print('📤 [WebSocketClient] sendMessage called - roomId: $roomId, content: "$content"');
    print('🔍 [WebSocketClient] Connection status - isConnected: $_isConnected, stompClient: ${_stompClient != null}');
    
    if (!_isConnected || _stompClient == null) {
      print('❌ [WebSocketClient] Cannot send message: WebSocket not connected');
      throw const WebSocketConnectionException('Cannot send message: WebSocket not connected');
    }
    
    if (content.trim().isEmpty) {
      print('❌ [WebSocketClient] Cannot send message: Content is empty');
      throw const ValidationException('Message content cannot be empty');
    }
    
    try {
      final messageData = {
        'content': content.trim(),
      };
      
      print('📨 [WebSocketClient] Sending message to /app/chat/$roomId: $messageData');
      
      _stompClient!.send(
        destination: '/app/chat/$roomId',
        body: json.encode(messageData),
      );
      
      print('✅ [WebSocketClient] Message sent successfully');
    } catch (e) {
      print('💥 [WebSocketClient] Error sending message: $e');
      throw WebSocketException('Failed to send message: $e');
    }
  }
  
  // Note: joinRoom and leaveRoom are not implemented in backend
  // Room membership is managed through REST API endpoints
  void joinRoom(String roomId) {
    // This functionality is handled by REST API, not WebSocket
    print('Room joining is handled via REST API, not WebSocket');
  }
  
  void leaveRoom(String roomId) {
    // This functionality is handled by REST API, not WebSocket
    print('Room leaving is handled via REST API, not WebSocket');
  }
  
  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
    _connectionController.add(false);
  }
  
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}