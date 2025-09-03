import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../../../data/models/notification_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = getIt<NotificationBloc>();
    _notificationBloc.add(const LoadNotifications());
    _notificationBloc.add(const InitializeNotificationSocket());
  }

  @override
  void dispose() {
    _notificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          title: Text(
            'Activity',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.primaryAccent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _notificationBloc.add(const RefreshNotifications());
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is NotificationError) {
              return Center(
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
                        _notificationBloc.add(const RefreshNotifications());
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(
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
                        'Chưa có thông báo nào',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),

                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  _notificationBloc.add(const RefreshNotifications());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(state.notifications[index]);
                  },
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Builds a notification item
  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      decoration: AppTheme.cardDecoration.copyWith(
        color: notification.isRead ? null : AppTheme.primaryAccent.withOpacity(0.05),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _notificationBloc.add(MarkNotificationAsRead(notification.id));
          }
          // Handle notification tap action
          if (notification.actionUrl != null) {
            // Navigate to action URL
          }
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: AppTheme.iconSizeMedium,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      notification.message,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
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
                        Text(
                          notification.typeDisplayName,
                          style: AppTheme.caption.copyWith(
                            color: _getNotificationColor(notification.type),
                          fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets notification color based on type
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.matchInvitation:
      case NotificationType.matchReminder:
        return AppTheme.primaryAccent;
      case NotificationType.achievement:
      case NotificationType.milestone:
        return Colors.amber.shade600;
      case NotificationType.teamInvitation:
      case NotificationType.teamUpdate:
        return AppTheme.secondaryAccent;
      case NotificationType.system:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.message:
        return Colors.purple;
      case NotificationType.friendRequest:
        return Colors.orange;
      case NotificationType.bookingConfirmation:
        return Colors.teal;
      case NotificationType.newBooking:
        return Colors.indigo;
      case NotificationType.newTournament:
        return Colors.red;
      case NotificationType.reviewRequest:
        return Colors.brown;
      case NotificationType.draftMatchInterest:
        return Colors.cyan;
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
      case NotificationType.achievement:
      case NotificationType.milestone:
        return Icons.emoji_events;
      case NotificationType.teamInvitation:
      case NotificationType.teamUpdate:
        return Icons.groups;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.bookingConfirmation:
        return Icons.check_circle;
      case NotificationType.newBooking:
        return Icons.event;
      case NotificationType.newTournament:
        return Icons.emoji_events;
      case NotificationType.reviewRequest:
        return Icons.rate_review;
      case NotificationType.draftMatchInterest:
        return Icons.sports;
      default:
        return Icons.notifications;
    }
  }
}