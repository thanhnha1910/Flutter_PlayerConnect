import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../services/websocket_service.dart';
import '../storage/secure_storage.dart';

@injectable
class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final SecureStorage _secureStorage;
  
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;
  
  WebSocketProvider({
    required WebSocketService webSocketService,
    required SecureStorage secureStorage,
  }) : _webSocketService = webSocketService,
       _secureStorage = secureStorage {
    _initializeConnection();
  }
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;
  WebSocketService get webSocketService => _webSocketService;
  
  // Streams
  Stream<Map<String, dynamic>> get notificationStream => _webSocketService.notificationStream;
  Stream<Map<String, dynamic>> get draftMatchStream => _webSocketService.draftMatchStream;
  Stream<Map<String, dynamic>> get matchStream => _webSocketService.matchStream;
  Stream<Map<String, dynamic>> get invitationStream => _webSocketService.invitationStream;
  
  Future<void> _initializeConnection() async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null) {
        await connect();
      }
    } catch (e) {
      print('Error initializing WebSocket connection: $e');
      _connectionError = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;
    
    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();
      
      await _webSocketService.connect();
      
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();
      
      print('WebSocket connected successfully');
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _connectionError = e.toString();
      notifyListeners();
      
      print('WebSocket connection failed: $e');
      rethrow;
    }
  }
  
  Future<void> disconnect() async {
    try {
      await _webSocketService.disconnect();
      _isConnected = false;
      _isConnecting = false;
      _connectionError = null;
      notifyListeners();
      
      print('WebSocket disconnected successfully');
    } catch (e) {
      print('Error disconnecting WebSocket: $e');
      _connectionError = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect();
  }
  
  // Draft match subscriptions
  void subscribeToDraftMatch(String draftMatchId) {
    _webSocketService.subscribeToDraftMatch(draftMatchId);
  }
  
  void unsubscribeFromDraftMatch(String draftMatchId) {
    _webSocketService.unsubscribeFromDraftMatch(draftMatchId);
  }
  
  // Send messages (if needed, can be added to WebSocketService later)
  // void sendMessage(String destination, Map<String, dynamic> message) {
  //   _webSocketService.sendMessage(destination, message);
  // }
  
  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}