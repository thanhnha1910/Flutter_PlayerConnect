import '../../../data/models/chat_message_model.dart';

abstract class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? sessionId;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.sessionId,
  });
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  const ChatLoading({
    required super.messages,
    super.sessionId,
  }) : super(isLoading: true);
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    required super.messages,
    super.sessionId,
  });
}

class ChatError extends ChatState {
  const ChatError({
    required String super.error,
    required super.messages,
    super.sessionId,
  });
}