abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String? sessionId;
  final Map<String, dynamic>? context;

  SendMessageEvent({
    required this.message,
    this.sessionId,
    this.context,
  });
}

class LoadChatHistoryEvent extends ChatEvent {
  final String sessionId;

  LoadChatHistoryEvent(this.sessionId);
}

class ClearChatEvent extends ChatEvent {}

class RetryMessageEvent extends ChatEvent {
  final String messageId;

  RetryMessageEvent(this.messageId);
}