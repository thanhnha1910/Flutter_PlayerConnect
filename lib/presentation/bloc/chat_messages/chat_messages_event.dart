import '../../../data/models/chat_message_model.dart';

abstract class ChatMessagesEvent {}

class LoadChatMessagesEvent extends ChatMessagesEvent {
  final String roomId;
  
  LoadChatMessagesEvent({required this.roomId});
}

class SendChatMessageEvent extends ChatMessagesEvent {
  final String roomId;
  final String content;
  final int userId;
  final String username;
  final DateTime sentAt;
  
  SendChatMessageEvent({
    required this.roomId,
    required this.content,
    required this.userId,
    required this.username,
    required this.sentAt,
  });
}

class SubscribeToRoomEvent extends ChatMessagesEvent {
  final String roomId;
  
  SubscribeToRoomEvent({required this.roomId});
}

class NewMessageReceivedEvent extends ChatMessagesEvent {
  final ChatMessageModel message;
  
  NewMessageReceivedEvent({required this.message});
}

class LoadMoreMessagesEvent extends ChatMessagesEvent {}

class DeleteChatMessageEvent extends ChatMessagesEvent {
  final String roomId;
  final String messageId;
  
  DeleteChatMessageEvent({
    required this.roomId,
    required this.messageId,
  });
}

class LoadChatRoomMembersEvent extends ChatMessagesEvent {
  final String roomId;
  
  LoadChatRoomMembersEvent({required this.roomId});
}

class InviteUserToChatRoomEvent extends ChatMessagesEvent {
  final String roomId;
  final String email;
  
  InviteUserToChatRoomEvent({
    required this.roomId,
    required this.email,
  });
}

class UnsubscribeFromRoomEvent extends ChatMessagesEvent {}