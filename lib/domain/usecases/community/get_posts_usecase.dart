import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@lazySingleton
class GetPostsUseCase {
  final CommunityRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<PostResponse>>> call(GetPostsParams params) async {
    print('calling');
    return await repository.getPosts(params.userId);
  }
}

class GetPostsParams extends Equatable {
  final int userId;

  const GetPostsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
