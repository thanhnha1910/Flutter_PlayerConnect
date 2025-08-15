import 'package:equatable/equatable.dart';

abstract class ChatRoomsEvent extends Equatable {
  const ChatRoomsEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRoomsEvent extends ChatRoomsEvent {
  const LoadChatRoomsEvent();
}

class CreateChatRoomEvent extends ChatRoomsEvent {
  final String name;
  final String? description;
  final int creatorUserId;

  const CreateChatRoomEvent({
    required this.name,
    this.description,
    required this.creatorUserId,
  });

  @override
  List<Object?> get props => [name, description, creatorUserId];
}

class JoinChatRoomEvent extends ChatRoomsEvent {
  final String roomId;

  const JoinChatRoomEvent(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class ConnectWebSocketEvent extends ChatRoomsEvent {
  const ConnectWebSocketEvent();
}

class RefreshChatRoomsEvent extends ChatRoomsEvent {
  const RefreshChatRoomsEvent();
}