import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chat_room_model.dart';
import '../chat/ai_chat_screen.dart';
import '../chat/chat_room_screen.dart';
import '../chat/create_chat_room_screen.dart';
import '../../bloc/chat_messages/chat_rooms_bloc.dart';
import '../../bloc/chat_messages/chat_rooms_event.dart';
import '../../bloc/chat_messages/chat_rooms_state.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late ChatRoomsBloc _chatRoomsBloc;

  @override
  void initState() {
    super.initState();
    _chatRoomsBloc = getIt<ChatRoomsBloc>();
    // Load chat rooms when screen initializes
    _chatRoomsBloc.add(const LoadChatRoomsEvent());
    // Connect WebSocket for real-time updates
    _chatRoomsBloc.add(const ConnectWebSocketEvent());
  }

  @override
  void dispose() {
    _chatRoomsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatRoomsBloc,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          title: Text(
            'Messages',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.primaryAccent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Handle search
              },
            ),
            IconButton(
              icon: const Icon(Icons.group_add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateChatRoomScreen(
                      chatRoomsBloc: _chatRoomsBloc,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ChatRoomsBloc, ChatRoomsState>(
          listener: (context, state) {
            if (state is ChatRoomsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ChatRoomsLoading) {
              return _buildLoadingState();
            } else if (state is ChatRoomsLoaded) {
              return _buildChatRoomsList(state.chatRooms);
            } else if (state is ChatRoomsError) {
              return _buildErrorState(state.message);
            } else {
              return _buildEmptyState();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateChatRoomScreen(
                  chatRoomsBloc: _chatRoomsBloc,
                ),
              ),
            );
          },
          backgroundColor: AppTheme.primaryAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  /// Builds loading state
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Builds error state
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Oops! Something went wrong',
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            message,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton(
            onPressed: () {
              _chatRoomsBloc.add(const LoadChatRoomsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Builds chat rooms list with AI Assistant always first
  Widget _buildChatRoomsList(List<ChatRoomModel> chatRooms) {
    return RefreshIndicator(
      onRefresh: () async {
        _chatRoomsBloc.add(const RefreshChatRoomsEvent());
        // Wait for refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        itemCount: chatRooms.length + 1, // +1 for AI Assistant
        itemBuilder: (context, index) {
          if (index == 0) {
            // AI Assistant always first
            return _buildAiAssistantTile();
          }
          
          final chatRoom = chatRooms[index - 1];
          return _buildChatRoomTile(chatRoom);
        },
      ),
    );
  }

  /// Builds AI Assistant tile
  Widget _buildAiAssistantTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        tileColor: AppTheme.surfaceColor,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: const Icon(
            Icons.smart_toy,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          'AI Assistant',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Ask me anything about sports...',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS,
            vertical: AppTheme.spacingXS,
          ),
          decoration: BoxDecoration(
            color: AppTheme.successColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Text(
            'Always available',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatScreen(),
            ),
          );
        },
      ),
    );
  }

  /// Builds chat room tile
  Widget _buildChatRoomTile(ChatRoomModel chatRoom) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        tileColor: AppTheme.surfaceColor,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getChatRoomColor(chatRoom.id),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: chatRoom.memberCount > 2
               ? const Icon(
                   Icons.group,
                   color: Colors.white,
                   size: 28,
                 )
               : Text(
                   chatRoom.name.isNotEmpty
                       ? chatRoom.name[0].toUpperCase()
                       : 'C',
                   style: AppTheme.headingMedium.copyWith(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
        ),
        title: Text(
          chatRoom.name,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          chatRoom.lastMessage ?? 'No messages yet',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chatRoom.lastMessageTime != null)
              Text(
                _formatTime(chatRoom.lastMessageTime!),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            // Removed unreadCount as it's not available in the new model
          ],
        ),
        onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => ChatRoomScreen(
                 roomId: chatRoom.id,
                 roomName: chatRoom.name,
               ),
             ),
           );
         },
      ),
    );
  }

  /// Gets color for chat room based on ID
    Color _getChatRoomColor(int roomId) {
      final colors = [
        AppTheme.primaryAccent,
        AppTheme.secondaryAccent,
        AppTheme.successColor,
        AppTheme.warningColor,
        AppTheme.errorColor,
      ];
      return colors[roomId.hashCode % colors.length];
    }

  /// Formats time for display
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  /// Builds empty state when no conversations
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No messages yet',
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Start a conversation with your teammates',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateChatRoomScreen(
                    chatRoomsBloc: _chatRoomsBloc,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Chat Room'),
          ),
        ],
      ),
    );
  }

  /// Builds a conversation item
  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingS,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _getAvatarColor(conversation['avatar']),
            child: conversation['isAI'] == true
                ? Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: AppTheme.iconSizeMedium,
                  )
                : conversation['isGroup']
                    ? Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: AppTheme.iconSizeMedium,
                      )
                    : Text(
                        conversation['avatar'],
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
          if (conversation['unreadCount'] > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  conversation['unreadCount'].toString(),
                  style: AppTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation['name'],
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: conversation['unreadCount'] > 0
              ? FontWeight.bold
              : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        conversation['lastMessage'],
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: conversation['unreadCount'] > 0
              ? FontWeight.w500
              : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            conversation['time'],
            style: AppTheme.caption.copyWith(
              color: conversation['unreadCount'] > 0
                  ? AppTheme.primaryAccent
                  : AppTheme.textSecondary,
              fontWeight: conversation['unreadCount'] > 0
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          if (conversation['unreadCount'] > 0)
            const SizedBox(height: AppTheme.spacingXS),
        ],
      ),
      onTap: () {
        if (conversation['isAI'] == true) {
          // Navigate to AI Chat Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatScreen(),
            ),
          );
        } else {
          // Handle regular conversation tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening chat with ${conversation['name']}'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }

  /// Gets avatar color based on initials
  Color _getAvatarColor(String initials) {
    final colors = [
      AppTheme.primaryAccent,
      AppTheme.secondaryAccent,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[initials.hashCode % colors.length];
  }
}