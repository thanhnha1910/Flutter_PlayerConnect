// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostResponse _$PostResponseFromJson(Map<String, dynamic> json) => PostResponse(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  createdAt: json['createdAt'] as String?,
  userName: json['userName'] as String,
  userAvatar: json['userAvatar'] as String?,
  commentCount: (json['commentCount'] as num).toInt(),
  likeCount: (json['likeCount'] as num).toInt(),
  userLikeStatus: (json['userLikeStatus'] as num).toInt(),
);

Map<String, dynamic> _$PostResponseToJson(PostResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'commentCount': instance.commentCount,
      'likeCount': instance.likeCount,
      'userLikeStatus': instance.userLikeStatus,
    };

PostRequest _$PostRequestFromJson(Map<String, dynamic> json) => PostRequest(
  title: json['title'] as String,
  content: json['content'] as String?,
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$PostRequestToJson(PostRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'userId': instance.userId,
    };
