import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import '../../../data/models/chat_message_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class SubscribeToRoomUseCase {
  final ChatRepository repository;

  SubscribeToRoomUseCase(this.repository);

  Future<Either<Failure, Stream<ChatMessageModel>>> call(String roomId) async {
    try {
      await repository.subscribeToRoom(roomId);
      final stream = repository.messageStream;
      return Right(stream);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}