import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/data/models/comment_model.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object> get props => [];
}

class FetchPosts extends CommunityEvent {}

class LikePost extends CommunityEvent {
  final int postId;

  const LikePost(this.postId);

  @override
  List<Object> get props => [postId];
}

class CreatePost extends CommunityEvent {
  final PostRequest postRequest;

  const CreatePost(this.postRequest);

  @override
  List<Object> get props => [postRequest];
}

class FetchComments extends CommunityEvent {
  final int postId;

  const FetchComments(this.postId);

  @override
  List<Object> get props => [postId];
}

class AddComment extends CommunityEvent {
  final int postId;
  final String content;

  const AddComment({required this.postId, required this.content});

  @override
  List<Object> get props => [postId, content];
}

class LikeComment extends CommunityEvent {
  final int commentId;
  final int postId;

  const LikeComment({required this.commentId, required this.postId});

  @override
  List<Object> get props => [commentId, postId];
}

class ReplyComment extends CommunityEvent {
  final int parentCommentId;
  final int postId;
  final String content;

  const ReplyComment({required this.parentCommentId, required this.postId, required this.content});

  @override
  List<Object> get props => [parentCommentId, postId, content];
}

class GenerateAiContent extends CommunityEvent {
  final Uint8List imageBytes;

  const GenerateAiContent(this.imageBytes);

  @override
  List<Object> get props => [imageBytes];
}