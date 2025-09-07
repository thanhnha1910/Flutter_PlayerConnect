import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'notification_model.g.dart';

enum NotificationType {
  @JsonValue('FRIEND_REQUEST')
  friendRequest,
  @JsonValue('BOOKING_CONFIRMATION')
  bookingConfirmation,
  @JsonValue('BOOKING_REMINDER')
  bookingReminder,
  @JsonValue('MATCH_INVITATION')
  matchInvitation,
  @JsonValue('MATCH_REMINDER')
  matchReminder,
  @JsonValue('TEAM_INVITATION')
  teamInvitation,
  @JsonValue('TEAM_UPDATE')
  teamUpdate,
  @JsonValue('ACHIEVEMENT')
  achievement,
  @JsonValue('MILESTONE')
  milestone,
  @JsonValue('SYSTEM')
  system,
  @JsonValue('PAYMENT')
  payment,
  @JsonValue('MESSAGE')
  message,
  @JsonValue('NEW_BOOKING')
  newBooking,
  @JsonValue('NEW_TOURNAMENT')
  newTournament,
  @JsonValue('REVIEW_REQUEST')
  reviewRequest,
  @JsonValue('NEW_REVIEW')
  newReview,
  @JsonValue('DRAFT_MATCH_INTEREST')
  draftMatchInterest,
  @JsonValue('DRAFT_MATCH_ACCEPTED')
  draftMatchAccepted,
  @JsonValue('DRAFT_MATCH_REJECTED')
  draftMatchRejected,
  @JsonValue('DRAFT_MATCH_WITHDRAW')
  draftMatchWithdraw,
  @JsonValue('DRAFT_MATCH_CONVERTED')
  draftMatchConverted,
  @JsonValue('DRAFT_MATCH_UPDATED')
  draftMatchUpdated,
  @JsonValue('MATCH_JOINED')
  matchJoined,
  @JsonValue('MATCH_LEFT')
  matchLeft,
  @JsonValue('OTHER')
  other,
}

@JsonSerializable()
class NotificationModel extends Equatable {
  final int id;
  final String? recipientId;
  final String title;
  @JsonKey(name: 'content')
  final String message;
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  @JsonKey(name: 'relatedEntityId', fromJson: _actionUrlFromJson)
  final String? actionUrl;
  final String? imageUrl;
  @JsonKey(name: 'recipient')
  final Map<String, dynamic>? recipientData;

  const NotificationModel({
    required this.id,
    this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data,
    this.actionUrl,
    this.imageUrl,
    this.recipientData,
  });

  // Helper methods for type conversion
  static String? _actionUrlFromJson(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static NotificationType _typeFromJson(String? type) {
    if (type == null) return NotificationType.other;

    switch (type.toUpperCase()) {
      case 'FRIEND_REQUEST':
        return NotificationType.friendRequest;
      case 'BOOKING_CONFIRMATION':
        return NotificationType.bookingConfirmation;
      case 'BOOKING_REMINDER':
        return NotificationType.bookingReminder;
      case 'MATCH_INVITATION':
        return NotificationType.matchInvitation;
      case 'MATCH_REMINDER':
        return NotificationType.matchReminder;
      case 'TEAM_INVITATION':
        return NotificationType.teamInvitation;
      case 'TEAM_UPDATE':
        return NotificationType.teamUpdate;
      case 'ACHIEVEMENT':
        return NotificationType.achievement;
      case 'MILESTONE':
        return NotificationType.milestone;
      case 'SYSTEM':
        return NotificationType.system;
      case 'PAYMENT':
        return NotificationType.payment;
      case 'MESSAGE':
        return NotificationType.message;
      case 'NEW_BOOKING':
        return NotificationType.newBooking;
      case 'NEW_TOURNAMENT':
        return NotificationType.newTournament;
      case 'REVIEW_REQUEST':
        return NotificationType.reviewRequest;
      case 'NEW_REVIEW':
        return NotificationType.newReview;
      case 'DRAFT_MATCH_INTEREST':
        return NotificationType.draftMatchInterest;
      case 'DRAFT_MATCH_ACCEPTED':
        return NotificationType.draftMatchAccepted;
      case 'DRAFT_MATCH_REJECTED':
        return NotificationType.draftMatchRejected;
      case 'DRAFT_MATCH_WITHDRAW':
        return NotificationType.draftMatchWithdraw;
      case 'DRAFT_MATCH_CONVERTED':
        return NotificationType.draftMatchConverted;
      case 'DRAFT_MATCH_UPDATED':
        return NotificationType.draftMatchUpdated;
      case 'MATCH_JOINED':
        return NotificationType.matchJoined;
      case 'MATCH_LEFT':
        return NotificationType.matchLeft;
      default:
        return NotificationType.other;
    }
  }

  static String _typeToJson(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return 'FRIEND_REQUEST';
      case NotificationType.bookingConfirmation:
        return 'BOOKING_CONFIRMATION';
      case NotificationType.bookingReminder:
        return 'BOOKING_REMINDER';
      case NotificationType.matchInvitation:
        return 'MATCH_INVITATION';
      case NotificationType.matchReminder:
        return 'MATCH_REMINDER';
      case NotificationType.teamInvitation:
        return 'TEAM_INVITATION';
      case NotificationType.teamUpdate:
        return 'TEAM_UPDATE';
      case NotificationType.achievement:
        return 'ACHIEVEMENT';
      case NotificationType.milestone:
        return 'MILESTONE';
      case NotificationType.system:
        return 'SYSTEM';
      case NotificationType.payment:
        return 'PAYMENT';
      case NotificationType.message:
        return 'MESSAGE';
      case NotificationType.newBooking:
        return 'NEW_BOOKING';
      case NotificationType.newTournament:
        return 'NEW_TOURNAMENT';
      case NotificationType.reviewRequest:
        return 'REVIEW_REQUEST';
      case NotificationType.newReview:
        return 'NEW_REVIEW';
      case NotificationType.draftMatchInterest:
        return 'DRAFT_MATCH_INTEREST';
      case NotificationType.draftMatchAccepted:
        return 'DRAFT_MATCH_ACCEPTED';
      case NotificationType.draftMatchRejected:
        return 'DRAFT_MATCH_REJECTED';
      case NotificationType.draftMatchWithdraw:
        return 'DRAFT_MATCH_WITHDRAW';
      case NotificationType.draftMatchConverted:
        return 'DRAFT_MATCH_CONVERTED';
      case NotificationType.draftMatchUpdated:
        return 'DRAFT_MATCH_UPDATED';
      case NotificationType.matchJoined:
        return 'MATCH_JOINED';
      case NotificationType.matchLeft:
        return 'MATCH_LEFT';
      case NotificationType.other:
      default:
        return 'OTHER';
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    int? id,
    String? recipientId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? recipientData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      recipientData: recipientData ?? this.recipientData,
    );
  }

  // Helper methods
  bool get isUnread => !isRead;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.friendRequest:
        return 'Lời mời kết bạn';
      case NotificationType.bookingConfirmation:
        return 'Xác nhận đặt sân';
      case NotificationType.bookingReminder:
        return 'Nhắc nhở đặt sân';
      case NotificationType.matchInvitation:
        return 'Lời mời trận đấu';
      case NotificationType.matchReminder:
        return 'Nhắc nhở trận đấu';
      case NotificationType.teamInvitation:
        return 'Lời mời đội';
      case NotificationType.teamUpdate:
        return 'Cập nhật đội';
      case NotificationType.achievement:
        return 'Thành tích';
      case NotificationType.milestone:
        return 'Cột mốc';
      case NotificationType.system:
        return 'Hệ thống';
      case NotificationType.payment:
        return 'Thanh toán';
      case NotificationType.message:
        return 'Tin nhắn';
      case NotificationType.newBooking:
        return 'Đặt sân mới';
      case NotificationType.newTournament:
        return 'Giải đấu mới';
      case NotificationType.reviewRequest:
        return 'Yêu cầu đánh giá';
      case NotificationType.newReview:
        return 'Đánh giá mới';
      case NotificationType.draftMatchInterest:
        return 'Quan tâm trận đấu';
      case NotificationType.draftMatchAccepted:
        return 'Chấp nhận trận đấu';
      case NotificationType.draftMatchRejected:
        return 'Từ chối trận đấu';
      case NotificationType.draftMatchWithdraw:
        return 'Rút lui trận đấu';
      case NotificationType.draftMatchConverted:
        return 'Chuyển đổi trận đấu';
      case NotificationType.draftMatchUpdated:
        return 'Cập nhật trận đấu';
      case NotificationType.matchJoined:
        return 'Tham gia trận đấu';
      case NotificationType.matchLeft:
        return 'Rời trận đấu';
      case NotificationType.other:
        return 'Khác';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.friendRequest:
        return '👥';
      case NotificationType.bookingConfirmation:
        return '📅';
      case NotificationType.bookingReminder:
        return '⏰';
      case NotificationType.matchInvitation:
        return '⚽';
      case NotificationType.matchReminder:
        return '🏃';
      case NotificationType.teamInvitation:
        return '👥';
      case NotificationType.teamUpdate:
        return '📢';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.milestone:
        return '🎯';
      case NotificationType.system:
        return '🔔';
      case NotificationType.payment:
        return '💳';
      case NotificationType.message:
        return '💬';
      case NotificationType.newBooking:
        return '📅';
      case NotificationType.newTournament:
        return '🏆';
      case NotificationType.reviewRequest:
        return '⭐';
      case NotificationType.newReview:
        return '📝';
      case NotificationType.draftMatchInterest:
        return '👀';
      case NotificationType.draftMatchAccepted:
        return '✅';
      case NotificationType.draftMatchRejected:
        return '❌';
      case NotificationType.draftMatchWithdraw:
        return '↩️';
      case NotificationType.draftMatchConverted:
        return '🔄';
      case NotificationType.draftMatchUpdated:
        return '📝';
      case NotificationType.matchJoined:
        return '➕';
      case NotificationType.matchLeft:
        return '➖';
      case NotificationType.other:
        return '📝';
    }
  }

  @override
  List<Object?> get props => [
    id,
    recipientId,
    title,
    message,
    type,
    isRead,
    createdAt,
    readAt,
    data,
    actionUrl,
    imageUrl,
    recipientData,
  ];

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}
