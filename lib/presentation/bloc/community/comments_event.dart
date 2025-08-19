import 'package:equatable/equatable.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object> get props => [];
}

class FetchComments extends CommentsEvent {
  final int postId;

  const FetchComments(this.postId);

  @override
  List<Object> get props => [postId];
}

class AddComment extends CommentsEvent {
  final int postId;
  final String content;

  const AddComment({required this.postId, required this.content});

  @override
  List<Object> get props => [postId, content];
}

class ToggleCommentExpansion extends CommentsEvent {
  final int commentId;

  const ToggleCommentExpansion(this.commentId);

  @override
  List<Object> get props => [commentId];
}

class LikeComment extends CommentsEvent {
  final int commentId;

  const LikeComment(this.commentId);

  @override
  List<Object> get props => [commentId];
}

class ReplyToComment extends CommentsEvent {
  final int parentCommentId;
  final String content;

  const ReplyToComment({required this.parentCommentId, required this.content});

  @override
  List<Object> get props => [parentCommentId, content];
}
