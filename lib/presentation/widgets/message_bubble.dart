import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int currentUserId;
  final Function(dynamic)? onActionTap;
  final VoidCallback? onRetry;
  final VoidCallback? onDeleteMessage;
  final bool canDeleteMessage;
  final BuildContext? parentContext;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    this.onActionTap,
    this.onRetry,
    this.onDeleteMessage,
    this.canDeleteMessage = false,
    this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = _isOwnMessage();
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwnMessage) ...[
            // Own message: content first, then avatar
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: _buildMessageContent(isOwnMessage),
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            _buildAvatar(),
          ] else ...[
            // Other's message: avatar first, then content
            _buildAvatar(),
            const SizedBox(width: AppTheme.spacingS),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: _buildMessageContent(isOwnMessage),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isOwnMessage() {
    // Compare message userId with current user ID
    return message.userId == currentUserId;
  }

  Widget _buildAvatar() {
    final initials = _getUserInitials(_getDisplayName());
    final isAI = message.userId == 0;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isAI 
              ? [AppTheme.secondaryAccent, AppTheme.secondaryAccent.withOpacity(0.8)]
              : [AppTheme.primaryAccent, AppTheme.primaryAccent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAI ? AppTheme.secondaryAccent : AppTheme.primaryAccent).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.transparent,
        child: isAI 
            ? const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              )
            : Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final initials = _getUserInitials(_getDisplayName());
    final isCurrentUser = message.userId != 0; // Assuming current user has userId != 0
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isCurrentUser 
              ? [AppTheme.primaryAccent, AppTheme.primaryAccent.withOpacity(0.8)]
              : [AppTheme.secondaryAccent, AppTheme.secondaryAccent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCurrentUser ? AppTheme.primaryAccent : AppTheme.secondaryAccent).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.transparent,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(bool isOwnMessage) {
    return Column(
      crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Username and timestamp
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isOwnMessage ? [
              // Own message: time first, then name
              Text(
                _formatTime(message.sentAt ?? DateTime.now()),
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                _getDisplayName(),
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ] : [
              // Other's message: name first, then time
              Text(
                _getDisplayName(),
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                _formatTime(message.sentAt ?? DateTime.now()),
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Message bubble with delete action
        Row(
          mainAxisSize: MainAxisSize.min,
          children: isOwnMessage ? [
            // Own message: delete button first, then bubble
            if (canDeleteMessage) ...[
              _buildDeleteButton(),
              const SizedBox(width: 4),
            ],
            Flexible(child: _buildMessageBubble(isOwnMessage)),
          ] : [
            // Other's message: bubble first, then delete button
            Flexible(child: _buildMessageBubble(isOwnMessage)),
            if (canDeleteMessage) ...[
              const SizedBox(width: 4),
              _buildDeleteButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMessageBubble(bool isOwnMessage) {
    return GestureDetector(
      onLongPress: canDeleteMessage && parentContext != null ? () => _showDeleteMenu(parentContext!) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          gradient: isOwnMessage 
              ? LinearGradient(
                  colors: [AppTheme.primaryAccent, AppTheme.primaryAccent.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isOwnMessage ? null : AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppTheme.radiusL),
            topRight: const Radius.circular(AppTheme.radiusL),
            bottomLeft: Radius.circular(isOwnMessage ? AppTheme.radiusL : AppTheme.radiusS),
            bottomRight: Radius.circular(isOwnMessage ? AppTheme.radiusS : AppTheme.radiusL),
          ),
          boxShadow: [
            BoxShadow(
              color: isOwnMessage 
                  ? AppTheme.primaryAccent.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: isOwnMessage ? null : Border.all(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          message.content ?? 'Message content unavailable',
          style: AppTheme.bodyMedium.copyWith(
            color: isOwnMessage ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: canDeleteMessage && parentContext != null ? () => _showDeleteMenu(parentContext!) : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.errorColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.delete_outline,
          size: 16,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingS),
      child: GestureDetector(
        onTap: onRetry,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: AppTheme.iconSizeSmall,
              color: AppTheme.errorColor,
            ),
            const SizedBox(width: AppTheme.spacingXS),
            Text(
              'Retry',
              style: AppTheme.caption.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildActionButtons removed - actions not available in new ChatMessage model

  Widget _buildActionButton(dynamic action) {
    return GestureDetector(
      onTap: () => onActionTap?.call(action),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: AppTheme.primaryAccent,
            width: 1,
          ),
        ),
        child: Text(
          action['label'] ?? action.toString(),
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.primaryAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getDisplayName() {
    // For AI messages (userId == 0)
    if (message.userId == 0) {
      return 'AI Assistant';
    }
    
    // For user messages, use actual username from message
    return message.username ?? 'Người dùng';
  }

  String _getUserInitials(String? username) {
    if (username == null || username.isEmpty) return 'U';
    final words = username.split(' ');
    if (words.length > 1) {
      return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildMessageInfo(bool isUser) {
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 0 : AppTheme.spacingXXXL,
        right: isUser ? AppTheme.spacingXXXL : 0,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            _formatTime(message.sentAt ?? DateTime.now()),
            style: AppTheme.caption,
          ),
          if (isUser) ...[
            const SizedBox(width: AppTheme.spacingXS),
            // Status icon removed
          ],
        ],
      ),
    );
  }

  // _buildStatusIcon removed - status not available in new ChatMessage model

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _showDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusL),
            topRight: Radius.circular(AppTheme.radiusL),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                ),
                title: Text(
                  'Xóa tin nhắn',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteMessage(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.cancel_outlined,
                  color: AppTheme.textSecondary,
                ),
                title: Text(
                  'Hủy',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Xóa tin nhắn',
          style: AppTheme.headlineSmall,
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tin nhắn này không?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteMessage?.call();
            },
            child: Text(
              'Xóa',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}