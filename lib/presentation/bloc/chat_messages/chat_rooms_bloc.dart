import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/chat/get_chat_rooms_usecase.dart';
import '../../../domain/usecases/chat/create_chat_room_usecase.dart';
import '../../../domain/usecases/chat/join_chat_room_usecase.dart';
import '../../../domain/usecases/chat/connect_websocket_usecase.dart';
import '../../../data/models/chat_room_model.dart';
import 'chat_rooms_event.dart';
import 'chat_rooms_state.dart';

@injectable
class ChatRoomsBloc extends Bloc<ChatRoomsEvent, ChatRoomsState> {
  final GetChatRoomsUseCase _getChatRoomsUseCase;
  final CreateChatRoomUseCase _createChatRoomUseCase;
  final JoinChatRoomUseCase _joinChatRoomUseCase;
  final ConnectWebSocketUseCase _connectWebSocketUseCase;

  ChatRoomsBloc({
    required GetChatRoomsUseCase getChatRoomsUseCase,
    required CreateChatRoomUseCase createChatRoomUseCase,
    required JoinChatRoomUseCase joinChatRoomUseCase,
    required ConnectWebSocketUseCase connectWebSocketUseCase,
  }) : _getChatRoomsUseCase = getChatRoomsUseCase,
       _createChatRoomUseCase = createChatRoomUseCase,
       _joinChatRoomUseCase = joinChatRoomUseCase,
       _connectWebSocketUseCase = connectWebSocketUseCase,
       super(ChatRoomsInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<CreateChatRoomEvent>(_onCreateChatRoom);
    on<JoinChatRoomEvent>(_onJoinChatRoom);
    on<ConnectWebSocketEvent>(_onConnectWebSocket);
    on<RefreshChatRoomsEvent>(_onRefreshChatRooms);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRoomsEvent event,
    Emitter<ChatRoomsState> emit,
  ) async {
    emit(ChatRoomsLoading());
    
    final result = await _getChatRoomsUseCase();
    
    result.fold(
      (failure) => emit(ChatRoomsError(failure.message)),
      (chatRooms) => emit(ChatRoomsLoaded(chatRooms)),
    );
  }

  Future<void> _onCreateChatRoom(
    CreateChatRoomEvent event,
    Emitter<ChatRoomsState> emit,
  ) async {
    emit(ChatRoomsCreating());
    
    final params = CreateChatRoomParams(
      name: event.name,
      description: event.description,
      creatorUserId: event.creatorUserId,
    );
    
    final result = await _createChatRoomUseCase(params);
    
    result.fold(
      (failure) => emit(ChatRoomsError(failure.message)),
      (chatRoom) {
        // Reload chat rooms after creating
        add(LoadChatRoomsEvent());
        emit(ChatRoomCreated(chatRoom));
      },
    );
  }

  Future<void> _onJoinChatRoom(
    JoinChatRoomEvent event,
    Emitter<ChatRoomsState> emit,
  ) async {
    emit(ChatRoomsJoining());
    
    final result = await _joinChatRoomUseCase(event.roomId);
    
    result.fold(
      (failure) => emit(ChatRoomsError(failure.message)),
      (_) {
        // Reload chat rooms after joining
        add(LoadChatRoomsEvent());
        emit(ChatRoomJoined(event.roomId));
      },
    );
  }

  Future<void> _onConnectWebSocket(
    ConnectWebSocketEvent event,
    Emitter<ChatRoomsState> emit,
  ) async {
    print('🔌 [ChatRoomsBloc] _onConnectWebSocket called - Starting WebSocket connection process');
    print('📊 [ChatRoomsBloc] Current state before connection: ${state.runtimeType}');
    
    print('🚀 [ChatRoomsBloc] Calling _connectWebSocketUseCase...');
    final result = await _connectWebSocketUseCase();
    
    print('📨 [ChatRoomsBloc] _connectWebSocketUseCase completed, processing result...');
    
    result.fold(
      (failure) {
        print('❌ [ChatRoomsBloc] WebSocket connection failed: ${failure.message}');
        print('🔄 [ChatRoomsBloc] Emitting ChatRoomsError state');
        emit(ChatRoomsError(failure.message));
      },
      (_) {
        print('✅ [ChatRoomsBloc] WebSocket connection successful');
        print('🔄 [ChatRoomsBloc] Emitting WebSocketConnected state');
        emit(WebSocketConnected());
      },
    );
    
    print('🏁 [ChatRoomsBloc] _onConnectWebSocket completed');
  }

  Future<void> _onRefreshChatRooms(
    RefreshChatRoomsEvent event,
    Emitter<ChatRoomsState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await _getChatRoomsUseCase();
    
    result.fold(
      (failure) => emit(ChatRoomsError(failure.message)),
      (chatRooms) => emit(ChatRoomsLoaded(chatRooms)),
    );
  }
}