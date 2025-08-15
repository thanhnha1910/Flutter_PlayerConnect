import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/usecases/send_chatbot_message_usecase.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/chatbot_models.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendChatbotMessageUseCase _sendMessageUseCase;
  final Uuid _uuid = const Uuid();

  ChatBloc({required SendChatbotMessageUseCase sendChatbotMessageUseCase}) 
      : _sendMessageUseCase = sendChatbotMessageUseCase,
        super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<ClearChatEvent>(_onClearChat);
    on<RetryMessageEvent>(_onRetryMessage);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentMessages = List<ChatMessage>.from(state.messages);
    final sessionId = event.sessionId ?? state.sessionId ?? _uuid.v4();
    
    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4().hashCode,
      userId: 1, // Default user
      username: 'User',
      content: event.message,
      sentAt: DateTime.now(),
    );
    
    currentMessages.add(userMessage);
    emit(ChatLoading(messages: currentMessages, sessionId: sessionId));
    
    // Send to AI
    final params = SendChatbotMessageParams(
      message: event.message,
      sessionId: sessionId,
      context: event.context,
    );
    
    final result = await _sendMessageUseCase(params);
    
    result.fold(
      (failure) {
        emit(ChatError(
          error: failure.message,
          messages: currentMessages,
          sessionId: sessionId,
        ));
      },
      (response) {
        final aiMessage = ChatMessage(
          id: _uuid.v4().hashCode,
          userId: 0, // AI user
          username: 'AI Assistant',
          content: response.responseText,
          sentAt: DateTime.now(),
        );
        
        currentMessages.add(aiMessage);
        emit(ChatLoaded(
          messages: currentMessages,
          sessionId: sessionId,
        ));
      },
    );
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Implementation for loading chat history from local storage
    // For now, just emit initial state with welcome message
    final welcomeMessage = ChatMessage(
      id: _uuid.v4().hashCode,
      userId: 0, // AI user
      username: 'AI Assistant',
      content: 'Xin chào! Tôi là AI Assistant. Tôi có thể giúp bạn tìm sân, đặt lịch, và trả lời các câu hỏi về dịch vụ. Bạn cần hỗ trợ gì?',
      sentAt: DateTime.now(),
    );
    
    emit(ChatLoaded(
      messages: [welcomeMessage],
      sessionId: event.sessionId,
    ));
  }

  Future<void> _onClearChat(
    ClearChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatInitial());
  }

  Future<void> _onRetryMessage(
    RetryMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Implementation for retrying failed messages
    final currentMessages = List<ChatMessage>.from(state.messages);
    final messageIndex = currentMessages.indexWhere(
      (msg) => msg.id == event.messageId,
    );
    
    if (messageIndex != -1) {
      final message = currentMessages[messageIndex];
      if (message.userId != 0) { // Not AI message
        // Retry sending the user message
        add(SendMessageEvent(
          message: message.content ?? '',
          sessionId: state.sessionId,
        ));
      }
    }
  }
}