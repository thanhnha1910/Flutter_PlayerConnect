import '../../../data/models/chat_room_model.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetChatRoomsUseCase {
  final ChatRepository repository;

  GetChatRoomsUseCase(this.repository);

  Future<Either<Failure, List<ChatRoomModel>>> call() async {
    try {
      final result = await repository.getChatRooms();
      return Right(result);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}