import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@lazySingleton
class AddCommentUseCase {
  final CommunityRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<Failure, CommentResponse>> call(AddCommentParams params) async {
    return await repository.createComment(params.postId, params.userId, params.request);
  }
}

class AddCommentParams extends Equatable {
  final int postId;
  final int userId;
  final CommentRequest request;

  const AddCommentParams({required this.postId, required this.userId, required this.request});

  @override
  List<Object?> get props => [postId, userId, request];
}
