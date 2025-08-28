import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/notification/notification_state.dart';
import '../bloc/notification/notification_event.dart';
import '../../data/models/notification_model.dart';
import 'notification_item.dart';

class NotificationDropdown extends StatelessWidget {
  final VoidCallback? onClose;

  const NotificationDropdown({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Thông báo',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoaded && state.unreadCount > 0) {
                    return TextButton(
                      onPressed: () {
                        context.read<NotificationBloc>().add(
                          const MarkAllNotificationsAsRead(),
                        );
                      },
                      child: Text(
                        'Đánh dấu tất cả đã đọc',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                iconSize: AppTheme.iconSizeSmall,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // Content
        Flexible(
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is NotificationError) {
                return Container(
                  height: 200,
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Không thể tải thông báo',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      TextButton(
                        onPressed: () {
                          context.read<NotificationBloc>().add(
                            const RefreshNotifications(),
                          );
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (state is NotificationLoaded) {
                if (state.notifications.isEmpty) {
                  return Container(
                    height: 200,
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Chưa có thông báo nào',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show only first 5 notifications in dropdown
                final displayNotifications = state.notifications.take(5).toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayNotifications.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppTheme.borderColor,
                      ),
                      itemBuilder: (context, index) {
                        return NotificationItem(
                          notification: displayNotifications[index],
                          isCompact: true,
                          onTap: () {
                            _handleNotificationTap(
                              context,
                              displayNotifications[index],
                            );
                          },
                        );
                      },
                    ),
                    if (state.notifications.length > 5)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            onClose?.call();
                            // Navigate to full notifications screen
                            Navigator.of(context).pushNamed('/notifications');
                          },
                          child: Text(
                            'Xem tất cả (${state.notifications.length})',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Mark as read if unread
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationAsRead(notification.id),
      );
    }

    // Close dropdown
    onClose?.call();

    // Handle navigation based on notification type and action URL
    if (notification.actionUrl != null) {
      // Navigate to the specific URL/route
      Navigator.of(context).pushNamed(notification.actionUrl!);
    } else {
      // Default navigation based on notification type
      switch (notification.type) {
        case 'match_invitation':
        case 'match_reminder':
          Navigator.of(context).pushNamed('/matches');
          break;
        case 'team_invitation':
        case 'team_update':
          Navigator.of(context).pushNamed('/teams');
          break;
        case 'message':
          Navigator.of(context).pushNamed('/messages');
          break;
        default:
          // Stay on current screen or navigate to notifications list
          break;
      }
    }
  }
}