import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@lazySingleton
class GetCommentsUseCase {
  final CommunityRepository repository;

  GetCommentsUseCase(this.repository);

  Future<Either<Failure, List<CommentResponse>>> call(GetCommentsParams params) async {
    return await repository.getCommentsForPost(params.postId, params.userId);
  }
}

class GetCommentsParams extends Equatable {
  final int postId;
  final int userId;

  const GetCommentsParams({required this.postId, required this.userId});

  @override
  List<Object?> get props => [postId, userId];
}