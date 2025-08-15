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
    required List<ChatMessage> messages,
    String? sessionId,
  }) : super(messages: messages, isLoading: true, sessionId: sessionId);
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    required List<ChatMessage> messages,
    String? sessionId,
  }) : super(messages: messages, sessionId: sessionId);
}

class ChatError extends ChatState {
  const ChatError({
    required String error,
    required List<ChatMessage> messages,
    String? sessionId,
  }) : super(messages: messages, error: error, sessionId: sessionId);
}