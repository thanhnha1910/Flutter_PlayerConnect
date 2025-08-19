import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/datasources/community_remote_datasource.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@LazySingleton(as: CommunityRepository)
class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PostResponse>> createPost(PostRequest request) async {
    try {
      final postResponse = await remoteDataSource.createPost(request);
      return Right(postResponse);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostResponse>>> getPosts(int userId) async {
    try {
      print('Getting post in repository impl');
      final posts = await remoteDataSource.getPosts(userId);
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(int postId, int userId) async {
    try {
      await remoteDataSource.likePost(postId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentResponse>>> getCommentsForPost(int postId, int userId) async {
    try {
      final comments = await remoteDataSource.getCommentsForPost(postId, userId);
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentResponse>> createComment(int postId, int userId, CommentRequest request) async {
    try {
      final comment = await remoteDataSource.createComment(postId, userId, request);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likeComment(int commentId, int userId) async {
    try {
      await remoteDataSource.likeComment(commentId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentResponse>> replyToComment(int parentCommentId, ReplyCommentRequest request) async {
    try {
      final comment = await remoteDataSource.replyToComment(parentCommentId, request);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}