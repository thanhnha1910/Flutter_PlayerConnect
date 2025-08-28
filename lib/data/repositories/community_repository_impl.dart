import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/datasources/community_remote_datasource.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/data/models/draft_match_model.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/data/models/user_model.dart';
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

  // Draft Match implementations
  @override
  Future<Either<Failure, DraftMatchResponse>> createDraftMatch(CreateDraftMatchRequest request) async {
    try {
      final draftMatch = await remoteDataSource.createDraftMatch(request);
      return Right(draftMatch);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchListResponse>> getActiveDraftMatches({String? sportType, bool? aiRanked}) async {
    try {
      final draftMatches = await remoteDataSource.getActiveDraftMatches(sportType: sportType, aiRanked: aiRanked);
      return Right(draftMatches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchListResponse>> getMyDraftMatches() async {
    try {
      final draftMatches = await remoteDataSource.getMyDraftMatches();
      return Right(draftMatches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchListResponse>> getPublicDraftMatches({String? sportType, bool? aiRanked}) async {
    try {
      final draftMatches = await remoteDataSource.getPublicDraftMatches(sportType: sportType, aiRanked: aiRanked);
      return Right(draftMatches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> expressInterest(int draftMatchId) async {
    try {
      final draftMatch = await remoteDataSource.expressInterest(draftMatchId);
      return Right(draftMatch);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> withdrawInterest(int draftMatchId) async {
    try {
      final draftMatch = await remoteDataSource.withdrawInterest(draftMatchId);
      return Right(draftMatch);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> acceptUser(int draftMatchId, int userId) async {
    try {
      final draftMatch = await remoteDataSource.acceptUser(draftMatchId, userId);
      return Right(draftMatch);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> rejectUser(int draftMatchId, int userId) async {
    try {
      final draftMatch = await remoteDataSource.rejectUser(draftMatchId, userId);
      return Right(draftMatch);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> convertToMatch(int draftMatchId) async {
    try {
      final draftMatch = await remoteDataSource.convertToMatch(draftMatchId);
      return Right(draftMatch);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> updateDraftMatch(int draftMatchId, CreateDraftMatchRequest request) async {
    try {
      final draftMatch = await remoteDataSource.updateDraftMatch(draftMatchId, request);
      return Right(draftMatch);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getInterestedUsers(int draftMatchId) async {
    try {
      final users = await remoteDataSource.getInterestedUsers(draftMatchId);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchListResponse>> getRankedDraftMatches({String? sportType}) async {
    try {
      final draftMatches = await remoteDataSource.getRankedDraftMatches(sportType: sportType);
      return Right(draftMatches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchListResponse>> getDraftMatchesWithUserInfo({String? sportType}) async {
    try {
      final draftMatches = await remoteDataSource.getDraftMatchesWithUserInfo(sportType: sportType);
      return Right(draftMatches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> initiateDraftMatchBooking(int draftMatchId, Map<String, dynamic> bookingData) async {
    try {
      final result = await remoteDataSource.initiateDraftMatchBooking(draftMatchId, bookingData);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DraftMatchResponse>> completeDraftMatchBooking(int draftMatchId, int bookingId) async {
    try {
      final result = await remoteDataSource.completeDraftMatchBooking(draftMatchId, bookingId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}