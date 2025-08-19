import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@lazySingleton
class ReplyCommentUseCase {
  final CommunityRepository repository;

  ReplyCommentUseCase(this.repository);

  Future<Either<Failure, CommentResponse>> call(ReplyCommentParams params) async {
    return await repository.replyToComment(params.parentCommentId, params.request);
  }
}

class ReplyCommentParams extends Equatable {
  final int parentCommentId;
  final ReplyCommentRequest request;

  const ReplyCommentParams({required this.parentCommentId, required this.request});

  @override
  List<Object?> get props => [parentCommentId, request];
}
