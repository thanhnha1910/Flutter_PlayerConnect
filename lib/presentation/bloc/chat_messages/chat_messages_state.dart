import '../../../data/models/chat_message_model.dart';

abstract class ChatMessagesState {}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<ChatMessageModel> messages;
  final String roomId;
  final bool hasMoreMessages;
  final int currentPage;
  final List<dynamic> members;
  
  ChatMessagesLoaded({
    required this.messages,
    required this.roomId,
    this.hasMoreMessages = true,
    this.currentPage = 0,
    this.members = const [],
  });
  
  ChatMessagesLoaded copyWith({
    List<ChatMessageModel>? messages,
    String? roomId,
    bool? hasMoreMessages,
    int? currentPage,
    List<dynamic>? members,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      roomId: roomId ?? this.roomId,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      currentPage: currentPage ?? this.currentPage,
      members: members ?? this.members,
    );
  }
}

class ChatMessagesLoadingMore extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  
  ChatMessagesLoadingMore(this.previousState);
}

class ChatMessageSending extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  
  ChatMessageSending(this.previousState);
}

class ChatMessagesError extends ChatMessagesState {
  final String message;
  
  ChatMessagesError({required this.message});
}

class ChatRoomMembersLoading extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  
  ChatRoomMembersLoading(this.previousState);
}

class ChatRoomMembersLoaded extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  final List<dynamic> members;
  
  ChatRoomMembersLoaded(this.previousState, this.members);
}

class ChatRoomMembersError extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  final String message;
  
  ChatRoomMembersError(this.previousState, this.message);
}

class UserInviteLoading extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  
  UserInviteLoading(this.previousState);
}

class UserInviteSuccess extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  final String message;
  
  UserInviteSuccess(this.previousState, this.message);
}

class UserInviteError extends ChatMessagesState {
  final ChatMessagesLoaded previousState;
  final String message;
  
  UserInviteError(this.previousState, this.message);
}