import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@lazySingleton
class LikeCommentUseCase {
  final CommunityRepository repository;

  LikeCommentUseCase(this.repository);

  Future<Either<Failure, void>> call(LikeCommentParams params) async {
    return await repository.likeComment(params.commentId, params.userId);
  }
}

class LikeCommentParams extends Equatable {
  final int commentId;
  final int userId;

  const LikeCommentParams({required this.commentId, required this.userId});

  @override
  List<Object?> get props => [commentId, userId];
}