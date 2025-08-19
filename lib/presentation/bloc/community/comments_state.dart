import 'package:equatable/equatable.dart';
import 'package:player_connect/data/models/comment_model.dart';

abstract class CommentsState extends Equatable {
  final int? postId;

  const CommentsState({this.postId});

  @override
  List<Object> get props => [postId!];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentResponse> comments;
  final List<CommentResponse> originalComments;

  const CommentsLoaded(this.comments, this.originalComments, int postId)
      : super(postId: postId);

  @override
  List<Object> get props => [comments, originalComments];
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object> get props => [message];
}

class CommentAdded extends CommentsState {}

class CommentAdding extends CommentsState {}

class CommentAddError extends CommentsState {
  final String message;

  const CommentAddError(this.message);

  @override
  List<Object> get props => [message];
}
