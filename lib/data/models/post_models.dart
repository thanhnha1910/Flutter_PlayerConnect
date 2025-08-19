import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'post_models.g.dart';

@JsonSerializable()
class PostResponse extends Equatable {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? createdAt;
  final String userName;
  final String? userAvatar;
  final int commentCount;
  final int likeCount;
  final int userLikeStatus;

  const PostResponse({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.createdAt,
    required this.userName,
    this.userAvatar,
    required this.commentCount,
    required this.likeCount,
    required this.userLikeStatus,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    final originalImageUrl = json['imageUrl'] as String?;
    final modifiedImageUrl = originalImageUrl?.replaceFirst('localhost', '10.0.2.2');
    print('modified: $modifiedImageUrl');

    return _$PostResponseFromJson(json)
        .copyWith(imageUrl: modifiedImageUrl);
  }

  Map<String, dynamic> toJson() => _$PostResponseToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        imageUrl,
        createdAt,
        userName,
        userAvatar,
        commentCount,
        likeCount,
        userLikeStatus,
      ];

  PostResponse copyWith({
    int? id,
    String? title,
    String? content,
    String? imageUrl,
    String? createdAt,
    String? userName,
    String? userAvatar,
    int? commentCount,
    int? likeCount,
    int? userLikeStatus,
  }) {
    return PostResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      userLikeStatus: userLikeStatus ?? this.userLikeStatus,
    );
  }
}

@JsonSerializable()
class PostRequest extends Equatable {
  final String title;
  final String? content;
  final int userId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final http.MultipartFile? image;

  const PostRequest({
    required this.title,
    this.content,
    required this.userId,
    this.image,
  });

  factory PostRequest.fromJson(Map<String, dynamic> json) =>
      _$PostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PostRequestToJson(this);

  PostRequest copyWith({
    String? title,
    String? content,
    int? userId,
    http.MultipartFile? image,
  }) {
    return PostRequest(
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [
        title,
        content,
        userId,
        image,
      ];
}
