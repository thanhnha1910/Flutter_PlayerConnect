import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentResponse extends Equatable {
  final int id;
  final String content;
  final String userName;
  final String? userAvatar;
  final String createdAt;
  final int userLikeStatus;
  final List<CommentResponse> childComments;
  final int level;
  final bool isExpanded;

  const CommentResponse({
    required this.id,
    required this.content,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
    required this.userLikeStatus,
    this.childComments = const [],
    this.level = 0,
    this.isExpanded = false,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CommentResponseToJson(this);

  List<CommentResponse> flattenComments([int level = 0]) {
    final List<CommentResponse> flattenedList = [];
    flattenedList.add(copyWith(level: level));
    if (isExpanded) {
      for (final child in childComments) {
        flattenedList.addAll(child.flattenComments(level + 1));
      }
    }
    return flattenedList;
  }

  CommentResponse copyWith({
    int? id,
    String? content,
    String? userName,
    String? userAvatar,
    String? createdAt,
    int? userLikeStatus,
    List<CommentResponse>? childComments,
    int? level,
    bool? isExpanded,
  }) {
    return CommentResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      createdAt: createdAt ?? this.createdAt,
      userLikeStatus: userLikeStatus ?? this.userLikeStatus,
      childComments: childComments ?? this.childComments,
      level: level ?? this.level,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        userName,
        userAvatar,
        createdAt,
        userLikeStatus,
        childComments,
        level,
        isExpanded,
      ];
}

@JsonSerializable()
class CommentRequest extends Equatable {
  final String content;

  const CommentRequest({
    required this.content,
  });

  factory CommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CommentRequestToJson(this);

  @override
  List<Object?> get props => [
        content,
      ];
}

@JsonSerializable()
class ReplyCommentRequest extends Equatable {
  final String content;
  final int postId;
  final int userId;

  const ReplyCommentRequest({
    required this.content,
    required this.postId,
    required this.userId,
  });

  factory ReplyCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$ReplyCommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReplyCommentRequestToJson(this);

  @override
  List<Object?> get props => [
        content,
        postId,
        userId,
      ];
}