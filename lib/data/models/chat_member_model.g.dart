// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMemberModel _$ChatMemberModelFromJson(Map<String, dynamic> json) =>
    ChatMemberModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      isAdmin: json['isAdmin'] as bool,
      isCreator: json['isCreator'] as bool,
      isActive: json['isActive'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$ChatMemberModelToJson(ChatMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'fullName': instance.fullName,
      'isAdmin': instance.isAdmin,
      'isCreator': instance.isCreator,
      'isActive': instance.isActive,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
