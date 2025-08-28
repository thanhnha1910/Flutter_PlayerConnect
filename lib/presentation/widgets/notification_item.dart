import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/notification_model.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/notification/notification_event.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final bool isCompact;
  final VoidCallback? onTap;
  final bool showActions;

  const NotificationItem({
    super.key,
    required this.notification,
    this.isCompact = false,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          isCompact ? AppTheme.spacingM : AppTheme.spacingL,
        ),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Colors.transparent 
              : AppTheme.primaryAccent.withOpacity(0.05),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: isCompact ? 40 : 48,
              height: isCompact ? 40 : 48,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type),
                borderRadius: BorderRadius.circular(
                  isCompact ? 20 : 24,
                ),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: isCompact ? AppTheme.iconSizeSmall : AppTheme.iconSizeMedium,
              ),
            ),
            SizedBox(width: isCompact ? AppTheme.spacingS : AppTheme.spacingM),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and unread indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: (isCompact 
                              ? AppTheme.bodySmall 
                              : AppTheme.bodyMedium).copyWith(
                            fontWeight: notification.isRead 
                                ? FontWeight.normal 
                                : FontWeight.bold,
                          ),
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: AppTheme.spacingS),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  // Content
                  if (notification.message.isNotEmpty) ...[
                    SizedBox(height: isCompact ? 2 : AppTheme.spacingXS),
                    Text(
                      notification.message,
                      style: (isCompact 
                          ? AppTheme.caption 
                          : AppTheme.bodySmall).copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: isCompact ? 1 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Time and type
                  SizedBox(height: isCompact ? 4 : AppTheme.spacingS),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: AppTheme.iconSizeSmall,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        notification.timeAgo,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (!isCompact) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: Text(
                            notification.typeDisplayName,
                            style: AppTheme.caption.copyWith(
                              color: _getNotificationColor(notification.type),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Actions (only for non-compact mode)
                  if (!isCompact && showActions && !notification.isRead)
                    Padding(
                      padding: const EdgeInsets.only(top: AppTheme.spacingS),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              context.read<NotificationBloc>().add(
                                MarkNotificationAsRead(notification.id),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: AppTheme.spacingXS,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Đánh dấu đã đọc',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.primaryAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          TextButton(
                            onPressed: () {
                              _showDeleteConfirmation(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: AppTheme.spacingXS,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Xóa',
                              style: AppTheme.caption.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa thông báo'),
          content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                context.read<NotificationBloc>().add(
                  DeleteNotification(notification.id),
                );
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  /// Gets notification color based on type
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.matchInvitation:
      case NotificationType.matchReminder:
        return AppTheme.primaryAccent;
      case NotificationType.friendRequest:
        return Colors.blue;
      case NotificationType.teamInvitation:
      case NotificationType.teamUpdate:
        return AppTheme.secondaryAccent;
      case NotificationType.bookingConfirmation:
      case NotificationType.bookingReminder:
        return Colors.orange;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.achievement:
        return Colors.purple;
      case NotificationType.milestone:
        return Colors.amber;
      case NotificationType.message:
        return Colors.teal;
      default:
        return AppTheme.textSecondary;
    }
  }

  /// Gets notification icon based on type
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.matchInvitation:
      case NotificationType.matchReminder:
        return Icons.sports_soccer;
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.teamInvitation:
      case NotificationType.teamUpdate:
        return Icons.groups;
      case NotificationType.bookingConfirmation:
      case NotificationType.bookingReminder:
        return Icons.event;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.milestone:
        return Icons.flag;
      case NotificationType.message:
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
}