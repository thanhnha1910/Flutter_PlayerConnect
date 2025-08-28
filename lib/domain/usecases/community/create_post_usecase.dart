import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';

@lazySingleton
class CreatePostUseCase {
  final CommunityRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<Failure, PostResponse>> call(PostRequest params) async {
    return await repository.createPost(params);
  }
}