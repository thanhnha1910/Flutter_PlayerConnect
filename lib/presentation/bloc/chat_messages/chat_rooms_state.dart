import 'package:equatable/equatable.dart';
import '../../../data/models/chat_room_model.dart';

abstract class ChatRoomsState extends Equatable {
  const ChatRoomsState();

  @override
  List<Object?> get props => [];
}

class ChatRoomsInitial extends ChatRoomsState {
  const ChatRoomsInitial();
}

class ChatRoomsLoading extends ChatRoomsState {
  const ChatRoomsLoading();
}

class ChatRoomsLoaded extends ChatRoomsState {
  final List<ChatRoomModel> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object> get props => [chatRooms];
}

class ChatRoomsError extends ChatRoomsState {
  final String message;

  const ChatRoomsError(this.message);

  @override
  List<Object> get props => [message];
}

class ChatRoomsCreating extends ChatRoomsState {
  const ChatRoomsCreating();
}

class ChatRoomCreated extends ChatRoomsState {
  final ChatRoomModel chatRoom;

  const ChatRoomCreated(this.chatRoom);

  @override
  List<Object> get props => [chatRoom];
}

class ChatRoomsJoining extends ChatRoomsState {
  const ChatRoomsJoining();
}

class ChatRoomJoined extends ChatRoomsState {
  final String roomId;

  const ChatRoomJoined(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class WebSocketConnected extends ChatRoomsState {
  const WebSocketConnected();
}