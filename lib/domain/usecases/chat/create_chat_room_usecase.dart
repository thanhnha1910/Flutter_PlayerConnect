import '../../../data/models/chat_room_model.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class CreateChatRoomParams {
  final String name;
  final String? description;
  final int creatorUserId;

  CreateChatRoomParams({
    required this.name,
    this.description,
    required this.creatorUserId,
  });
}

@injectable
class CreateChatRoomUseCase {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  Future<Either<Failure, ChatRoomModel>> call(CreateChatRoomParams params) async {
    try {
      final result = await repository.createChatRoom(params.name, params.description, params.creatorUserId);
      return Right(result);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}