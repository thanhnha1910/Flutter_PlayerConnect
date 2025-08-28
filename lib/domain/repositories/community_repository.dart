import 'package:dartz/dartz.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/data/models/draft_match_model.dart';
import 'package:player_connect/data/models/user_model.dart';

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
  
  // Draft Match methods
  Future<Either<Failure, DraftMatchResponse>> createDraftMatch(CreateDraftMatchRequest request);
  Future<Either<Failure, DraftMatchListResponse>> getActiveDraftMatches({String? sportType, bool? aiRanked});
  Future<Either<Failure, DraftMatchListResponse>> getMyDraftMatches();
  Future<Either<Failure, DraftMatchListResponse>> getPublicDraftMatches({String? sportType, bool? aiRanked});
  Future<Either<Failure, DraftMatchListResponse>> getRankedDraftMatches({String? sportType});
  Future<Either<Failure, DraftMatchListResponse>> getDraftMatchesWithUserInfo({String? sportType});
  Future<Either<Failure, DraftMatchResponse>> expressInterest(int draftMatchId);
  Future<Either<Failure, DraftMatchResponse>> withdrawInterest(int draftMatchId);
  Future<Either<Failure, DraftMatchResponse>> acceptUser(int draftMatchId, int userId);
  Future<Either<Failure, DraftMatchResponse>> rejectUser(int draftMatchId, int userId);
  Future<Either<Failure, DraftMatchResponse>> convertToMatch(int draftMatchId);
  Future<Either<Failure, DraftMatchResponse>> updateDraftMatch(int draftMatchId, CreateDraftMatchRequest request);
  Future<Either<Failure, List<UserModel>>> getInterestedUsers(int draftMatchId);
  Future<Either<Failure, DraftMatchResponse>> initiateDraftMatchBooking(int draftMatchId, Map<String, dynamic> bookingData);
  Future<Either<Failure, DraftMatchResponse>> completeDraftMatchBooking(int draftMatchId, int bookingId);
}