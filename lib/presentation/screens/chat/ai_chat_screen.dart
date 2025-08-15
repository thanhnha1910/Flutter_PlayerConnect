import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';

import '../../../domain/usecases/send_chatbot_message_usecase.dart';
import '../../bloc/chatbot/chat_bloc.dart';
import '../../bloc/chatbot/chat_event.dart';
import '../../bloc/chatbot/chat_state.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input.dart';
import '../../widgets/typing_indicator.dart';

class AiChatScreen extends StatelessWidget {
  final String? sessionId;
  
  const AiChatScreen({super.key, this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        sendChatbotMessageUseCase: getIt<SendChatbotMessageUseCase>(),
      )..add(LoadChatHistoryEvent(sessionId ?? 'default')),
      child: _AiChatView(sessionId: sessionId),
    );
  }
}

class _AiChatView extends StatefulWidget {
  final String? sessionId;
  
  const _AiChatView({this.sessionId});

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryAccent,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: AppTheme.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<ChatBloc>().add(ClearChatEvent());
              context.read<ChatBloc>().add(
                LoadChatHistoryEvent(widget.sessionId ?? 'default'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          // Auto scroll to bottom when new message arrives
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length && state.isLoading) {
                      return const TypingIndicator();
                    }
                    
                    final message = state.messages[index];
                    return MessageBubble(
                      message: message,
                      currentUserId: 0, // AI chat doesn't have user ID comparison
                      onActionTap: (action) {
                        _handleActionTap(context, action);
                      },
                      onRetry: () {
                        context.read<ChatBloc>().add(
                          RetryMessageEvent(message.id?.toString() ?? ''),
                        );
                      },
                    );
                  },
                ),
              ),
              MessageInput(
                controller: _messageController,
                onSend: (message) {
                  if (message.trim().isNotEmpty) {
                    context.read<ChatBloc>().add(
                      SendMessageEvent(
                        message: message,
                        sessionId: state.sessionId,
                      ),
                    );
                    _messageController.clear();
                  }
                },
                enabled: !state.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleActionTap(BuildContext context, dynamic action) {
    final actionType = action['type'] as String?;
    switch (actionType) {
      case 'action':
        final payload = action['payload'] as Map<String, dynamic>? ?? {};
        final subActionType = payload['action'] as String?;
        switch (subActionType) {
          case 'book_field':
            final fieldId = payload['fieldId'] as String?;
            if (fieldId != null) {
              // Navigate to booking screen
              // Navigator.pushNamed(context, '/booking', arguments: fieldId);
              _showSnackBar(context, 'Navigating to booking for field: $fieldId');
            }
            break;
          case 'view_matches':
            // Navigate to matches screen
            // Navigator.pushNamed(context, '/matches');
            _showSnackBar(context, 'Navigating to matches screen');
            break;
          case 'find_fields':
            final location = payload['location'] as String?;
            // Navigate to explore screen with location filter
            // Navigator.pushNamed(context, '/explore', arguments: location);
            _showSnackBar(context, 'Finding fields near: ${location ?? "your location"}');
            break;
          default:
            _showSnackBar(context, 'Action: ${action['label'] ?? action.toString()}');
        }
        break;
      case 'quick_reply':
        // Send the quick reply as a new message
        final payload = action['payload'] as Map<String, dynamic>? ?? {};
        final replyText = payload['text'] as String?;
        if (replyText != null) {
          context.read<ChatBloc>().add(
            SendMessageEvent(
              message: replyText,
              sessionId: context.read<ChatBloc>().state.sessionId,
            ),
          );
        }
        break;
      case 'url':
        final payload = action['payload'] as Map<String, dynamic>? ?? {};
        final url = payload['url'] as String?;
        if (url != null) {
          // Open URL in browser
          // launchUrl(Uri.parse(url));
          _showSnackBar(context, 'Opening URL: $url');
        }
        break;
      default:
        _showSnackBar(context, 'Unknown action type: ${actionType ?? "unknown"}');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}