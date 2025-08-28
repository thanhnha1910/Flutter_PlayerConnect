// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      recipientId: json['recipientId'] as String?,
      title: json['title'] as String,
      message: json['content'] as String,
      type: NotificationModel._typeFromJson(json['type'] as String?),
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: NotificationModel._actionUrlFromJson(json['relatedEntityId']),
      imageUrl: json['imageUrl'] as String?,
      recipientData: json['recipient'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'title': instance.title,
      'content': instance.message,
      'type': NotificationModel._typeToJson(instance.type),
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'data': instance.data,
      'relatedEntityId': instance.actionUrl,
      'imageUrl': instance.imageUrl,
      'recipient': instance.recipientData,
    };
