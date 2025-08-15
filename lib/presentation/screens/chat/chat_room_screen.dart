import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/presentation/bloc/chat_messages/chat_rooms_bloc.dart';
import 'package:player_connect/presentation/bloc/chat_messages/chat_rooms_event.dart';
import 'package:player_connect/presentation/bloc/chat_messages/chat_rooms_state.dart';
import '../../../core/di/injection.dart';

import '../../../data/models/chat_message_model.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/chat_messages/chat_messages_bloc.dart';
import '../../bloc/chat_messages/chat_messages_event.dart';
import '../../bloc/chat_messages/chat_messages_state.dart';


import '../../widgets/message_bubble.dart';
import '../../widgets/message_input.dart';
import '../../widgets/typing_indicator.dart';
import '../../widgets/chat_settings_modal.dart';

class ChatRoomScreen extends StatefulWidget {
  final int roomId;
  final String? roomName;

  const ChatRoomScreen({
    Key? key,
    required this.roomId,
    this.roomName,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  late ChatMessagesBloc _chatMessagesBloc;
  late AuthBloc _authBloc;
  late ChatRoomsBloc _chatRoomsBloc;
  final TextEditingController _messageController = TextEditingController();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _chatMessagesBloc = getIt<ChatMessagesBloc>();
    _chatRoomsBloc = getIt<ChatRoomsBloc>();
    _scrollController.addListener(_onScroll);
    
    // Connect WebSocket for real-time messaging
    _chatRoomsBloc.add(ConnectWebSocketEvent());
    // Load chat room members
    _chatMessagesBloc.add(LoadChatRoomMembersEvent(roomId: widget.roomId.toString()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get AuthBloc from context instead of creating new instance
    _authBloc = BlocProvider.of<AuthBloc>(context);
    
    // Check initial AuthBloc state
    if (_authBloc.state is Authenticated) {
      _currentUser = (_authBloc.state as Authenticated).user;
    } else {
      print('⚠️ [ChatRoomScreen] AuthBloc not authenticated: ${_authBloc.state.runtimeType}');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _chatRoomsBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _chatMessagesBloc.add(LoadMoreMessagesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _chatMessagesBloc
            ..add(LoadChatMessagesEvent(roomId: widget.roomId.toString()))
            ..add(SubscribeToRoomEvent(roomId: widget.roomId.toString())),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is Authenticated) {
            _currentUser = authState.user;
          } else {
            _currentUser = null;
            
            // Redirect to login screen if user is not authenticated
            if (authState is Unauthenticated || authState is AuthInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/login');
              });
            }
          }
        },
        child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.roomName ?? 'Chat Room',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          actions: [
            BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
              builder: (context, state) {
                
                List<dynamic> members = [];
                if (state is ChatMessagesLoaded) {
                  members = state.members;
                  
                } 
                return IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    print('⚙️ [ChatRoomScreen] Settings button pressed with ${members.length} members');
                    showModalBottomSheet(
                       context: context,
                       isScrollControlled: true,
                       backgroundColor: Colors.transparent,
                       builder: (context) => ChatSettingsModal(
                         roomId: widget.roomId.toString(),
                         roomName: widget.roomName ?? 'Chat Room',
                         onMembersUpdated: (updatedMembers) {
                           setState(() {
                             members = updatedMembers;
                           });
                         },
                         onChatDeleted: () {
                           // Reload members when there are changes
                           _chatMessagesBloc.add(LoadChatRoomMembersEvent(roomId: widget.roomId.toString()));
                         },
                       ),
                     );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ChatMessagesBloc, ChatMessagesState>(
          listener: (context, state) {
            
           
            
            if (state is ChatMessagesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            
           
            
            return Column(
              children: [
                Expanded(
                  child: _buildMessagesList(state),
                ),
                _buildMessageInput(state),
              ],
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildMessagesList(ChatMessagesState state) {
    if (state is ChatMessagesLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is ChatMessagesLoaded) {
      if (state.messages.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 24),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Start the conversation!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: state.messages.length + (state.hasMoreMessages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.messages.length) {
              // Load more indicator
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            final message = state.messages[state.messages.length - 1 - index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 12),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOutBack,
                )),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: ModalRoute.of(context)!.animation!,
                    curve: Curves.easeIn,
                  )),
                  child: MessageBubble(
                    message: ChatMessage(
                      id: message.id,
                      userId: message.userId,
                      username: message.username ?? 'Unknown User',
                      content: message.content ,
                      sentAt: message.sentAt ?? DateTime.now(),
                    ),
                    currentUserId: _currentUser?.id ?? 0,
                    canDeleteMessage: _canDeleteMessage(message),
                    onDeleteMessage: () => _deleteMessage(message),
                    parentContext: context,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    if (state is ChatMessagesLoadingMore) {
      return _buildMessagesList(state.previousState);
    }

    if (state is ChatMessageSending) {
      return _buildMessagesList(state.previousState);
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageInput(ChatMessagesState state) {
    final isLoading = state is ChatMessageSending;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOut,
                )),
                child: const TypingIndicator(),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            child: MessageInput(
              controller: _messageController,
              onSend: (message) {
               
                if (_currentUser != null) {
                 
                  _chatMessagesBloc.add(
                    SendChatMessageEvent(
                      roomId: widget.roomId.toString(),
                      content: message,
                      userId: _currentUser!.id,
                      username: _currentUser!.username,
                      sentAt: DateTime.now(),
                    ),
                  );
                  _messageController.clear();
                  _scrollToBottom();
                } else {
                  
                }
              },
              enabled: !isLoading,
            ),
          ),
        ],
      ),
    );
  }

  bool _isMyMessage(ChatMessageModel message) {
    if (_currentUser == null) return false;
    return message.userId == _currentUser!.id;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _canDeleteMessage(ChatMessageModel message) {
    if (_currentUser == null) return false;
    return message.userId == _currentUser!.id;
  }

  void _deleteMessage(ChatMessageModel message) {
    _chatMessagesBloc.add(
      DeleteChatMessageEvent(
        roomId: widget.roomId.toString(),
        messageId: message.id.toString(),
      ),
    );
  }
}