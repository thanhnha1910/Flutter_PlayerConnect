import 'package:equatable/equatable.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/data/models/post_models.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<PostResponse> posts;

  const CommunityLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class CommunityError extends CommunityState {
  final String message;

  const CommunityError(this.message);

  @override
  List<Object> get props => [message];
}

class CreatePostSuccess extends CommunityState {}

class CreatePostFailure extends CommunityState {
  final String message;

  const CreatePostFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CommentsLoading extends CommunityState {}

class CommentsLoaded extends CommunityState {
  final List<CommentResponse> comments;

  const CommentsLoaded(this.comments);

  @override
  List<Object> get props => [comments];
}

class CommentsError extends CommunityState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object> get props => [message];
}
