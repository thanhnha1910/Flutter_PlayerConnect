import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/notification/notification_state.dart';
import '../bloc/notification/notification_event.dart';
import '../../data/models/notification_model.dart';
import 'notification_item.dart';

class NotificationList extends StatefulWidget {
  final bool showHeader;
  final String? filterType;
  final EdgeInsets? padding;

  const NotificationList({
    super.key,
    this.showHeader = true,
    this.filterType,
    this.padding,
  });

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  void _loadMoreNotifications() {
    if (_isLoadingMore) return;

    final state = context.read<NotificationBloc>().state;
    if (state is NotificationLoaded && !state.hasReachedMax) {
      setState(() {
        _isLoadingMore = true;
      });
      
      context.read<NotificationBloc>().add(
        const LoadMoreNotifications(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationLoaded) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      },
      child: Column(
        children: [
          // Header with actions
          if (widget.showHeader)
            Container(
              padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  Text(
                    'Thông báo',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoaded && state.unreadCount > 0) {
                        return Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                context.read<NotificationBloc>().add(
                                  const MarkAllNotificationsAsRead(),
                                );
                              },
                              child: Text(
                                'Đánh dấu tất cả đã đọc',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Filter button
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (String value) {
                      if (value == 'all') {
                        context.read<NotificationBloc>().add(
                          const FilterNotifications(isRead: null),
                        );
                      } else {
                        context.read<NotificationBloc>().add(
                          FilterNotifications(type: value),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'all',
                        child: Text('Tất cả'),
                      ),
                      const PopupMenuItem(
                        value: 'MATCH_INVITATION',
                        child: Text('Lời mời trận đấu'),
                      ),
                      const PopupMenuItem(
                        value: 'TEAM_INVITATION',
                        child: Text('Lời mời đội'),
                      ),
                      const PopupMenuItem(
                        value: 'FRIEND_REQUEST',
                        child: Text('Lời mời kết bạn'),
                      ),
                      const PopupMenuItem(
                        value: 'BOOKING_CONFIRMATION',
                        child: Text('Xác nhận đặt sân'),
                      ),
                      const PopupMenuItem(
                        value: 'PAYMENT_SUCCESS',
                        child: Text('Thanh toán'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Notification list
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is NotificationError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Không thể tải thông báo',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            state.message,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          ElevatedButton(
                            onPressed: () {
                              context.read<NotificationBloc>().add(
                                const RefreshNotifications(),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is NotificationLoaded) {
                  final notifications = widget.filterType != null
                      ? state.notifications
                          .where((n) => n.type == widget.filterType)
                          .toList()
                      : state.notifications;

                  if (notifications.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              widget.filterType != null
                                  ? 'Không có thông báo loại này'
                                  : 'Chưa có thông báo nào',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotificationBloc>().add(
                        const RefreshNotifications(),
                      );
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: widget.padding ?? const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                      ),
                      itemCount: notifications.length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) {
                        if (index >= notifications.length) {
                          return const SizedBox.shrink();
                        }
                        return Divider(
                          height: 1,
                          color: AppTheme.borderColor,
                        );
                      },
                      itemBuilder: (context, index) {
                        if (index >= notifications.length) {
                          // Loading more indicator
                          return const Padding(
                            padding: EdgeInsets.all(AppTheme.spacingL),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final notification = notifications[index];
                        return NotificationItem(
                          notification: notification,
                          onTap: () => _handleNotificationTap(notification),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read if unread
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationAsRead(notification.id),
      );
    }

    // Handle navigation based on notification type and related entity
    if (notification.actionUrl != null) {
      // Navigate based on notification type and entity ID
      _navigateToRelatedEntity(notification);
    } else {
      // Default navigation based on notification type
      switch (notification.type) {
        case 'MATCH_INVITATION':
        case 'MATCH_REMINDER':
          Navigator.of(context).pushNamed('/matches');
          break;
        case 'TEAM_INVITATION':
        case 'TEAM_UPDATE':
          Navigator.of(context).pushNamed('/teams');
          break;
        case 'FRIEND_REQUEST':
        case 'FRIEND_ACCEPTED':
          Navigator.of(context).pushNamed('/friends');
          break;
        case 'BOOKING_CONFIRMATION':
        case 'BOOKING_CANCELLED':
          Navigator.of(context).pushNamed('/bookings');
          break;
        case 'PAYMENT_SUCCESS':
        case 'PAYMENT_FAILED':
          Navigator.of(context).pushNamed('/payments');
          break;
        default:
          // Show notification details in a dialog or bottom sheet
          _showNotificationDetails(notification);
          break;
      }
    }
  }

  void _navigateToRelatedEntity(NotificationModel notification) {
    // Navigate based on notification type and related entity ID
    switch (notification.type) {
      case 'FRIEND_REQUEST':
      case 'FRIEND_ACCEPTED':
        Navigator.of(context).pushNamed('/profile/${notification.actionUrl}');
        break;
      case 'BOOKING_CONFIRMATION':
      case 'BOOKING_CANCELLED':
        Navigator.of(context).pushNamed('/booking/${notification.actionUrl}');
        break;
      case 'MATCH_INVITATION':
      case 'MATCH_REMINDER':
        Navigator.of(context).pushNamed('/match/${notification.actionUrl}');
        break;
      case 'TEAM_INVITATION':
      case 'TEAM_UPDATE':
        Navigator.of(context).pushNamed('/team/${notification.actionUrl}');
        break;
      case 'PAYMENT_SUCCESS':
      case 'PAYMENT_FAILED':
        Navigator.of(context).pushNamed('/payment/${notification.actionUrl}');
        break;
      default:
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusL),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            // Title
            Text(
              notification.title,
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Message
            Text(
              notification.message,
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Time and type
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
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    notification.typeDisplayName,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}