import 'package:dartz/dartz.dart';
import 'package:player_connect/data/models/comment_model.dart';

import '../../core/error/failures.dart';
import '../../data/models/post_models.dart';

abstract class CommunityRepository {
  Future<Either<Failure, List<PostResponse>>> getPosts(int userId);
  Future<Either<Failure, PostResponse>> createPost(PostRequest request);
  Future<Either<Failure, void>> likePost(int postId, int userId);
  Future<Either<Failure, List<CommentResponse>>> getCommentsForPost(int postId, int userId);
  Future<Either<Failure, CommentResponse>> createComment(int postId, int userId, CommentRequest request);
  Future<Either<Failure, void>> likeComment(int commentId, int userId);
  Future<Either<Failure, CommentResponse>> replyToComment(int parentCommentId, ReplyCommentRequest request);
}