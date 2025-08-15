import '../../../data/models/chat_room_model.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/chat_member_model.dart';

abstract class ChatRepository {
  // Chat Rooms
  Future<List<ChatRoomModel>> getChatRooms();
  Future<ChatRoomModel> createChatRoom(String name, String? description, int creatorUserId);
  Future<ChatRoomModel> getChatRoom(String roomId);
  Future<void> joinChatRoom(String roomId);
  Future<void> leaveChatRoom(String roomId);
  
  // Chat Messages
  Future<List<ChatMessageModel>> getChatMessages(String roomId, {int page = 0, int size = 20});
  Future<ChatMessageModel> sendMessage(String roomId, String content);
  Future<void> deleteMessage(String roomId, String messageId);
  
  // Chat Members
  Future<List<ChatMemberModel>> getChatMembers(String roomId);
  Future<void> inviteUserToChatRoom(String roomId, String userEmail);
  Future<void> removeMemberFromChatRoom(String roomId, String memberId);
  Future<void> addMemberToChatRoom(String roomId, String userId);
  
  // Chat Room Management
  Future<void> deleteChatRoom(String roomId);
  Future<void> deleteAllMessages(String roomId);
  
  // WebSocket
  Stream<ChatMessageModel> get messageStream;
  Future<void> connectWebSocket();
  Future<void> disconnectWebSocket();
  Future<void> subscribeToRoom(String roomId);
  Future<void> unsubscribeFromRoom(String roomId);
  Future<void> sendMessageViaWebSocket(String roomId, String content);
}