import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../domain/usecases/chat/get_chat_messages_usecase.dart';
import '../../../domain/usecases/chat/send_message_usecase.dart';
import '../../../domain/usecases/chat/subscribe_to_room_usecase.dart';
import '../../../domain/usecases/chat/delete_message_usecase.dart';
import '../../../data/datasources/chat_remote_data_source.dart';
import 'chat_messages_event.dart';
import 'chat_messages_state.dart';

@injectable
class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final SubscribeToRoomUseCase _subscribeToRoomUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final ChatRemoteDataSource _chatRemoteDataSource;

  StreamSubscription? _messageSubscription;
  String? _currentRoomId;

  ChatMessagesBloc(
    this._getChatMessagesUseCase,
    this._sendMessageUseCase,
    this._subscribeToRoomUseCase,
    this._deleteMessageUseCase,
    this._chatRemoteDataSource,
  ) : super(ChatMessagesInitial()) {
    on<LoadChatMessagesEvent>(_onLoadChatMessages);
    on<SendChatMessageEvent>(_onSendChatMessage);
    on<SubscribeToRoomEvent>(_onSubscribeToRoom);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<LoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<DeleteChatMessageEvent>(_onDeleteChatMessage);
    on<UnsubscribeFromRoomEvent>(_onUnsubscribeFromRoom);
    on<LoadChatRoomMembersEvent>(_onLoadChatRoomMembers);
    on<InviteUserToChatRoomEvent>(_onInviteUserToChatRoom);
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    emit(ChatMessagesLoading());

    _currentRoomId = event.roomId;

    try {
      final result = await _getChatMessagesUseCase(
        GetChatMessagesParams(roomId: event.roomId),
      );

      result.fold(
        (failure) => emit(
          ChatMessagesError(
            message: 'Failed to load messages: ${failure.message}',
          ),
        ),
        (messages) {
          // Preserve members data if current state has it
          List<dynamic> existingMembers = [];
          if (state is ChatMessagesLoaded) {
            final currentState = state as ChatMessagesLoaded;
            existingMembers = currentState.members;
          }

          emit(
            ChatMessagesLoaded(
              messages: messages,
              roomId: event.roomId,
              hasMoreMessages: messages.length >= 20,
              currentPage: 0,
              members: existingMembers,
            ),
          );
        },
      );
    } catch (e) {
      emit(ChatMessagesError(message: 'Failed to load messages: $e'));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    
    
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      
      emit(ChatMessageSending(currentState));

      try {
        final result = await _sendMessageUseCase(
          SendMessageParams(
            roomId: event.roomId,
            content: event.content,
            userId: event.userId,
            username: event.username,
            sentAt: event.sentAt,
          ),
        );

       
        result.fold(
          (failure) {
            
            emit(
              ChatMessagesError(
                message: 'Failed to send message: ${failure.message}',
              ),
            );
          },
          (_) {
            // Message sent successfully via WebSocket
            // The actual message will be received via WebSocket subscription
           
            // Emit the current state back to reset from ChatMessageSending
            emit(currentState);
          },
        );
      } catch (e) {
        emit(ChatMessagesError(message: 'Failed to send message: $e'));
      }
    } else {
     
    }
  }

  Future<void> _onSubscribeToRoom(
    SubscribeToRoomEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    _currentRoomId = event.roomId;

    try {
      final result = await _subscribeToRoomUseCase(event.roomId);

      result.fold(
        (failure) => emit(
          ChatMessagesError(
            message: 'Failed to subscribe to room: ${failure.message}',
          ),
        ),
        (messageStream) {
          _messageSubscription?.cancel();
          _messageSubscription = messageStream.listen(
            (message) => add(NewMessageReceivedEvent(message: message)),
            onError: (error) =>
                emit(ChatMessagesError(message: 'Stream error: $error')),
          );
        },
      );
    } catch (e) {
      emit(ChatMessagesError(message: 'Failed to subscribe to room: $e'));
    }
  }

  void _onNewMessageReceived(
    NewMessageReceivedEvent event,
    Emitter<ChatMessagesState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;

      // Check for duplicate messages to prevent showing the same message multiple times
      final isDuplicate = currentState.messages.any((existingMessage) {
        // Check by ID first (most reliable) - both IDs must be non-null and greater than 0
        if (event.message.id != null &&
            event.message.id! > 0 &&
            existingMessage.id != null &&
            existingMessage.id! > 0) {
          return existingMessage.id == event.message.id;
        }

        // Fallback: check by content, userId, and timestamp (within 5 seconds)
        final timeDifference = event.message.timestamp
            .difference(existingMessage.timestamp)
            .abs();
        return existingMessage.content == event.message.content &&
            existingMessage.userId == event.message.userId &&
            timeDifference.inSeconds <= 5;
      });

      if (!isDuplicate) {
        final updatedMessages = List<ChatMessageModel>.from(
          currentState.messages,
        )..add(event.message);

        emit(currentState.copyWith(messages: updatedMessages));
      } else {
      }
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;

      if (!currentState.hasMoreMessages) return;

      emit(ChatMessagesLoadingMore(currentState));

      try {
        final nextPage = currentState.currentPage + 1;
        final result = await _getChatMessagesUseCase(
          GetChatMessagesParams(
            roomId: currentState.roomId,
            page: nextPage,
            size: 20,
          ),
        );

        result.fold(
          (failure) => emit(
            ChatMessagesError(
              message: 'Failed to load more messages: ${failure.message}',
            ),
          ),
          (newMessages) {
            final allMessages = List<ChatMessageModel>.from(
              currentState.messages,
            )..addAll(newMessages);

            emit(
              currentState.copyWith(
                messages: allMessages,
                hasMoreMessages: newMessages.length >= 20,
                currentPage: nextPage,
              ),
            );
          },
        );
      } catch (e) {
        emit(ChatMessagesError(message: 'Failed to load more messages: $e'));
      }
    }
  }

  Future<void> _onDeleteChatMessage(
    DeleteChatMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;

      try {
        final result = await _deleteMessageUseCase(
          DeleteMessageParams(roomId: event.roomId, messageId: event.messageId),
        );

        result.fold(
          (failure) => emit(
            ChatMessagesError(
              message: 'Failed to delete message: ${failure.message}',
            ),
          ),
          (_) {
            // Remove the message from the local state
            final updatedMessages = currentState.messages
                .where((message) => message.id.toString() != event.messageId)
                .toList();

            emit(currentState.copyWith(messages: updatedMessages));
          },
        );
      } catch (e) {
        emit(ChatMessagesError(message: 'Failed to delete message: $e'));
      }
    }
  }

  Future<void> _onLoadChatRoomMembers(
    LoadChatRoomMembersEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
  
    // Emit loading state regardless of current state
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
     
      emit(ChatRoomMembersLoading(currentState));
    } else {
     
    }

    try {
      final members = await _chatRemoteDataSource.getChatRoomMembers(
        event.roomId,
      );

     

      if (state is ChatMessagesLoaded) {
        // If current state is ChatMessagesLoaded, update it with members
        final currentState = state as ChatMessagesLoaded;
        emit(ChatRoomMembersLoaded(currentState, members));

        final updatedState = currentState.copyWith(members: members);
       
        
        emit(updatedState);
      } else {
        // If current state is not ChatMessagesLoaded, emit ChatRoomMembersLoaded with empty base state
       
        final emptyState = ChatMessagesLoaded(
          roomId: event.roomId,
          messages: [],
          hasMoreMessages: false,
          currentPage: 1,
          members: [],
        );
        emit(ChatRoomMembersLoaded(emptyState, members));

        // Then emit the updated state with members
        final updatedState = emptyState.copyWith(members: members);
       
        emit(updatedState);
      }

      
    } catch (e) {

      if (state is ChatMessagesLoaded) {
        final currentState = state as ChatMessagesLoaded;
        emit(ChatRoomMembersError(currentState, 'Failed to load members: $e'));
      } else {
        
        emit(ChatMessagesError(message: 'Failed to load members: $e'));
      }
    }
  }

  Future<void> _onInviteUserToChatRoom(
    InviteUserToChatRoomEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      emit(UserInviteLoading(currentState));

      try {
        await _chatRemoteDataSource.inviteUserToChatRoom(
          event.roomId,
          event.email,
        );
        emit(UserInviteSuccess(currentState, 'User invited successfully'));

        // Reload members after successful invite
        add(LoadChatRoomMembersEvent(roomId: event.roomId));
      } catch (e) {
        emit(UserInviteError(currentState, 'Failed to invite user: $e'));
      }
    }
  }

  void _onUnsubscribeFromRoom(
    UnsubscribeFromRoomEvent event,
    Emitter<ChatMessagesState> emit,
  ) {
    _messageSubscription?.cancel();
    _currentRoomId = null;
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
