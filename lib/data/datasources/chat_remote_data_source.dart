import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_member_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/storage/secure_storage.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoomModel>> getChatRooms();
  Future<ChatRoomModel> createChatRoom(String name, String? description, int creatorUserId);
  Future<ChatRoomModel> getChatRoom(String roomId);
  Future<List<ChatMessageModel>> getChatMessages(String roomId, {int page = 0, int size = 20});
  Future<ChatMessageModel> sendMessage(String roomId, String content);
  Future<void> deleteMessage(String roomId, String messageId);
  Future<void> joinChatRoom(String roomId);
  Future<void> leaveChatRoom(String roomId);
  Future<List<ChatMemberModel>> getChatMembers(String roomId);
  Future<void> inviteUserToChatRoom(String roomId, String userEmail);
  Future<void> removeMemberFromChatRoom(String roomId, String memberId);
  Future<List<dynamic>> getChatRoomMembers(String roomId);
  Future<void> deleteChatRoom(String roomId);
  Future<void> addMemberToChatRoom(String roomId, String userId);
  Future<void> deleteAllMessages(String roomId);
  Future<void> addMemberByEmail(String roomId, String email);
  Future<List<Map<String, dynamic>>> searchUsers(String query);
  Future<void> leaveRoom(String roomId);
  Future<void> deleteRoom(String roomId);
  Future<void> clearMessages(String roomId);
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final SecureStorage secureStorage;
  String? _authToken;

  ChatRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }



  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsEndpoint}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ChatRoomModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get chat rooms: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<ChatRoomModel> createChatRoom(String name, String? description, int creatorUserId) async {
    try {
      final requestBody = {
        'name': name,
        'creatorUserId': creatorUserId,
        if (description != null) 'description': description,
      };

      final headers = await _getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsCreateEndpoint}'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ChatRoomModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException('Failed to create chat room: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<ChatRoomModel> getChatRoom(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsEndpoint}/$roomId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ChatRoomModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException('Failed to get chat room: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatMessages(String roomId, {int page = 0, int size = 20}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsMessagesEndpoint.replaceAll('{roomId}', roomId)}?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ChatMessageModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get chat messages: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(String roomId, String content) async {
    try {
      final requestBody = {
        'content': content,
      };

      final headers = await _getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsMessagesEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ChatMessageModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> joinChatRoom(String roomId) async {
    // Note: Backend doesn't have a specific join endpoint
    // Users are automatically added to chat rooms when invited
    // This method is kept for compatibility but does nothing
    return;
  }

  @override
  Future<void> leaveChatRoom(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsLeaveEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to leave chat room: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<ChatMemberModel>> getChatMembers(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsMembersEndpoint.replaceAll('{chatRoomId}', roomId)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ChatMemberModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get chat members: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> inviteUserToChatRoom(String roomId, String userEmail) async {
    try {
      final requestBody = {
        'email': userEmail,
      };

      final headers = await _getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsInviteEndpoint.replaceAll('{chatRoomId}', roomId)}'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to invite user: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsDeleteMessageEndpoint.replaceAll('{roomId}', roomId).replaceAll('{messageId}', messageId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> removeMemberFromChatRoom(String roomId, String memberId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsRemoveMemberEndpoint.replaceAll('{roomId}', roomId).replaceAll('{userId}', memberId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to remove member: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<dynamic>> getChatRoomMembers(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = '$baseUrl${ApiConstants.chatRoomsMembersEndpoint.replaceAll('{chatRoomId}', roomId)}';
      
      // Debug logging - URL và headers
      print('=== getChatRoomMembers Debug ===');
      print('🌐 URL: $url');
      print('📋 Headers: $headers');
      print('🏠 Room ID: $roomId');
      
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      // Debug logging - Response status
      print('📡 Response Status Code: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        // Debug logging - Raw response
        print('📄 Raw Response Body: ${response.body}');
        
        final data = json.decode(response.body);
        print('🔍 Parsed Data Type: ${data.runtimeType}');
        print('🔍 Parsed Data: $data');
        
        List<dynamic> members;
        
        // Handle different response formats
        if (data is List) {
          // Direct array format
          members = data;
          print('✅ Format: Direct array');
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('members')) {
            // Object with 'members' key
            members = data['members'] as List<dynamic>? ?? [];
            print('✅ Format: Object with members key');
          } else if (data.containsKey('data') && data['data'] is Map && data['data']['members'] != null) {
            // Nested structure: data.data.members
            members = data['data']['members'] as List<dynamic>? ?? [];
            print('✅ Format: Nested data.data.members');
          } else if (data.containsKey('data') && data['data'] is List) {
            // Nested structure: data.data as array
            members = data['data'] as List<dynamic>? ?? [];
            print('✅ Format: Nested data.data as array');
          } else {
            // Fallback: try to find any array in the response
            final possibleArrays = data.values.where((value) => value is List).toList();
            if (possibleArrays.isNotEmpty) {
              members = possibleArrays.first as List<dynamic>;
              print('✅ Format: Found array in response values');
            } else {
              members = [];
              print('⚠️ Format: No array found, returning empty list');
            }
          }
        } else {
          members = [];
          print('❌ Format: Unexpected data type, returning empty list');
        }
        
        print('👥 Final Members Count: ${members.length}');
        print('👥 Final Members Data: $members');
        print('===============================');
        
        return members;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        print('===============================');
        throw ServerException('Failed to get chat room members: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception in getChatRoomMembers: $e');
      print('💥 Exception Type: ${e.runtimeType}');
      print('===============================');
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsDeleteEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete chat room: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> addMemberToChatRoom(String roomId, String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsAddMemberEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to add member: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> deleteAllMessages(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsMessagesEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete all messages: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> addMemberByEmail(String roomId, String email) async {
    try {
      final requestBody = {
        'email': email,
      };

      final headers = await _getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsInviteEndpoint.replaceAll('{chatRoomId}', roomId)}'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to add member by email: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl${ApiConstants.usersEndpoint}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        // Filter users based on query (search by name or email)
        if (query.isNotEmpty) {
          return users.where((user) {
            final name = (user['fullName'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            final searchQuery = query.toLowerCase();
            return name.contains(searchQuery) || email.contains(searchQuery);
          }).cast<Map<String, dynamic>>().toList();
        }
        return users.cast<Map<String, dynamic>>();
      } else {
        throw ServerException('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsLeaveEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to leave room: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsDeleteEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete room: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> clearMessages(String roomId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await client.delete(
        Uri.parse('$baseUrl${ApiConstants.chatRoomsClearMessagesEndpoint.replaceAll('{roomId}', roomId)}'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to clear messages: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }
}