import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_member_model.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/websocket_client.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/storage/secure_storage.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final WebSocketClient webSocketClient;
  final SecureStorage secureStorage;
  final AuthRepository authRepository;
  
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketClient,
    required this.secureStorage,
    required this.authRepository,
  });

  // Chat Rooms
  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      return await remoteDataSource.getChatRooms();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ChatRoomModel> createChatRoom(String name, String? description, int creatorUserId) async {
    try {
      return await remoteDataSource.createChatRoom(name, description, creatorUserId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ChatRoomModel> getChatRoom(String roomId) async {
    try {
      return await remoteDataSource.getChatRoom(roomId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> joinChatRoom(String roomId) async {
    try {
      await remoteDataSource.joinChatRoom(roomId);
      // Also join via WebSocket for real-time updates
      webSocketClient.joinRoom(roomId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> leaveChatRoom(String roomId) async {
    try {
      await remoteDataSource.leaveChatRoom(roomId);
      // Also leave via WebSocket
      webSocketClient.leaveRoom(roomId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  // Chat Messages
  @override
  Future<List<ChatMessageModel>> getChatMessages(String roomId, {int page = 0, int size = 20}) async {
    try {
      return await remoteDataSource.getChatMessages(roomId, page: page, size: size);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(String roomId, String content) async {
    try {
      // Send via REST API to ensure proper response and avoid duplicates
      return await remoteDataSource.sendMessage(roomId, content);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      await remoteDataSource.deleteMessage(roomId, messageId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  // Chat Members
  @override
  Future<List<ChatMemberModel>> getChatMembers(String roomId) async {
    try {
      return await remoteDataSource.getChatMembers(roomId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> inviteUserToChatRoom(String roomId, String userEmail) async {
    try {
      await remoteDataSource.inviteUserToChatRoom(roomId, userEmail);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> removeMemberFromChatRoom(String roomId, String memberId) async {
    try {
      await remoteDataSource.removeMemberFromChatRoom(roomId, memberId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  // WebSocket
  @override
  Stream<ChatMessageModel> get messageStream => webSocketClient.messageStream;

  @override
  Future<void> connectWebSocket() async {
    try {
      await _connectWebSocketWithRetry();
    } catch (e) {
      throw ServerFailure('Failed to connect WebSocket: $e');
    }
  }
  
  /// Validates if the token is still valid by checking its expiration
  Future<bool> _isTokenValid(String token) async {
    try {
      // Parse JWT token to check expiration
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }
      
      // Decode payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = payload.padRight(
        (payload.length + 3) ~/ 4 * 4,
        '=',
      );
      
      final decoded = Uri.decodeFull(String.fromCharCodes(
        base64Url.decode(normalizedPayload),
      ));
      
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);
      
      // Check if token has expiration time
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        
        // Add 5 minute buffer before expiration
        return exp > (currentTime + 300);
      }
      
      // If no expiration, consider token valid
      return true;
    } catch (e) {
      // If we can't parse the token, consider it invalid
      return false;
    }
  }
  
  Future<void> _connectWebSocketWithRetry({
    bool isRetry = false,
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    print('🔄 [ChatRepositoryImpl] _connectWebSocketWithRetry - Attempt ${retryCount + 1}/${maxRetries + 1}, isRetry: $isRetry');
    try {
      // Get token from SecureStorage
      print('🔑 [ChatRepositoryImpl] Getting token from SecureStorage...');
      final token = await secureStorage.getToken();
      
      if (token == null || token.isEmpty) {
        print('❌ [ChatRepositoryImpl] No authentication token available');
        throw ServerFailure('No authentication token available');
      }
      
      print('✅ [ChatRepositoryImpl] Token retrieved, validating...');
      // Validate token before attempting WebSocket connection
      if (!await _isTokenValid(token)) {
        print('⚠️ [ChatRepositoryImpl] Token is invalid, attempting refresh...');
        if (retryCount < maxRetries) {
          // Token is invalid, try to refresh
          final refreshResult = await authRepository.refreshToken();
          await refreshResult.fold(
            (failure) => throw ServerFailure('Token refresh failed: ${failure.message}'),
            (_) async {
              // Token refreshed successfully, retry connection with exponential backoff
              final delay = Duration(milliseconds: (1000 * (retryCount + 1) * (retryCount + 1))); // Exponential backoff
              await Future.delayed(delay);
              await _connectWebSocketWithRetry(
                isRetry: true,
                retryCount: retryCount + 1,
                maxRetries: maxRetries,
              );
              return;
            },
          );
        } else {
          throw ServerFailure('Token validation failed after $maxRetries retries');
        }
      }
      
      print('🔌 [ChatRepositoryImpl] Token valid, connecting to WebSocket...');
      await webSocketClient.connect(token);
      print('✅ [ChatRepositoryImpl] WebSocket connection successful');
    } on WebSocketAuthenticationException catch (e) {
      print('🔐 [ChatRepositoryImpl] WebSocket authentication error: ${e.message}');
      if (retryCount < maxRetries) {
        // Try to refresh token and retry
        final refreshResult = await authRepository.refreshToken();
        await refreshResult.fold(
          (failure) => throw ServerFailure('Token refresh failed: ${failure.message}'),
          (_) async {
            // Token refreshed successfully, retry connection with exponential backoff
            final delay = Duration(milliseconds: (1000 * (retryCount + 1) * (retryCount + 1))); // Exponential backoff
            await Future.delayed(delay);
            await _connectWebSocketWithRetry(
              isRetry: true,
              retryCount: retryCount + 1,
              maxRetries: maxRetries,
            );
          },
        );
      } else {
        // Max retries reached, authentication failed
        throw ServerFailure('WebSocket authentication failed after $maxRetries retries: ${e.message}');
      }
    } on WebSocketConnectionException catch (e) {
      print('🌐 [ChatRepositoryImpl] WebSocket connection error: ${e.message}');
      if (retryCount < maxRetries) {
        // Network/connection error, retry with exponential backoff
        final delay = Duration(milliseconds: (1000 * (retryCount + 1) * (retryCount + 1))); // Exponential backoff
        print('⏳ [ChatRepositoryImpl] Retrying connection in ${delay.inMilliseconds}ms...');
        await Future.delayed(delay);
        await _connectWebSocketWithRetry(
          isRetry: true,
          retryCount: retryCount + 1,
          maxRetries: maxRetries,
        );
      } else {
        print('💥 [ChatRepositoryImpl] Max retries reached for connection error');
        throw ServerFailure('WebSocket connection failed after $maxRetries retries: ${e.message}');
      }
    } catch (e) {
      print('💥 [ChatRepositoryImpl] Generic WebSocket error: $e');
      if (retryCount < maxRetries) {
        // Generic error, retry with exponential backoff
        final delay = Duration(milliseconds: (1000 * (retryCount + 1) * (retryCount + 1))); // Exponential backoff
        print('⏳ [ChatRepositoryImpl] Retrying connection in ${delay.inMilliseconds}ms...');
        await Future.delayed(delay);
        await _connectWebSocketWithRetry(
          isRetry: true,
          retryCount: retryCount + 1,
          maxRetries: maxRetries,
        );
      } else {
        print('💥 [ChatRepositoryImpl] Max retries reached for generic error');
        throw ServerFailure('Failed to connect WebSocket after $maxRetries retries: $e');
      }
    }
  }

  @override
  Future<void> disconnectWebSocket() async {
    try {
      webSocketClient.disconnect();
    } catch (e) {
      throw ServerFailure('Failed to disconnect WebSocket: $e');
    }
  }

  @override
  Future<void> subscribeToRoom(String roomId) async {
    try {
      webSocketClient.subscribeToRoom(roomId);
    } catch (e) {
      throw ServerFailure('Failed to subscribe to room: $e');
    }
  }

  @override
  Future<void> unsubscribeFromRoom(String roomId) async {
    try {
      webSocketClient.unsubscribeFromRoom(roomId);
    } catch (e) {
      throw ServerFailure('Failed to unsubscribe from room: $e');
    }
  }

  @override
  Future<void> sendMessageViaWebSocket(String roomId, String content) async {
    try {
      webSocketClient.sendMessage(roomId, content);
    } catch (e) {
      throw ServerFailure('Failed to send message via WebSocket: $e');
    }
  }

  @override
  Future<void> addMemberToChatRoom(String roomId, String userId) async {
    try {
      await remoteDataSource.addMemberToChatRoom(roomId, userId);
    } catch (e) {
      throw ServerFailure('Failed to add member to chat room: $e');
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      await remoteDataSource.deleteChatRoom(roomId);
    } catch (e) {
      throw ServerFailure('Failed to delete chat room: $e');
    }
  }

  @override
  Future<void> deleteAllMessages(String roomId) async {
    try {
      await remoteDataSource.deleteAllMessages(roomId);
    } catch (e) {
      throw ServerFailure('Failed to delete all messages: $e');
    }
  }
}