import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@lazySingleton
class LikePostUseCase {
  final CommunityRepository repository;

  LikePostUseCase(this.repository);

  Future<Either<Failure, void>> call(LikePostParams params) async {
    return await repository.likePost(params.postId, params.userId);
  }
}

class LikePostParams extends Equatable {
  final int postId;
  final int userId;

  const LikePostParams({required this.postId, required this.userId});

  @override
  List<Object?> get props => [postId, userId];
}
