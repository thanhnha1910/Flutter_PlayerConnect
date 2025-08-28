// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentResponse _$CommentResponseFromJson(Map<String, dynamic> json) =>
    CommentResponse(
      id: (json['id'] as num).toInt(),
      content: json['content'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      createdAt: json['createdAt'] as String,
      userLikeStatus: (json['userLikeStatus'] as num).toInt(),
      childComments:
          (json['childComments'] as List<dynamic>?)
              ?.map((e) => CommentResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      level: (json['level'] as num?)?.toInt() ?? 0,
      isExpanded: json['isExpanded'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentResponseToJson(CommentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'createdAt': instance.createdAt,
      'userLikeStatus': instance.userLikeStatus,
      'childComments': instance.childComments,
      'level': instance.level,
      'isExpanded': instance.isExpanded,
    };

CommentRequest _$CommentRequestFromJson(Map<String, dynamic> json) =>
    CommentRequest(content: json['content'] as String);

Map<String, dynamic> _$CommentRequestToJson(CommentRequest instance) =>
    <String, dynamic>{'content': instance.content};

ReplyCommentRequest _$ReplyCommentRequestFromJson(Map<String, dynamic> json) =>
    ReplyCommentRequest(
      content: json['content'] as String,
      postId: (json['postId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$ReplyCommentRequestToJson(
  ReplyCommentRequest instance,
) => <String, dynamic>{
  'content': instance.content,
  'postId': instance.postId,
  'userId': instance.userId,
};
