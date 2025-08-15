import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class JoinChatRoomUseCase {
  final ChatRepository repository;

  JoinChatRoomUseCase(this.repository);

  Future<Either<Failure, void>> call(String roomId) async {
    try {
      await repository.joinChatRoom(roomId);
      return const Right(null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}