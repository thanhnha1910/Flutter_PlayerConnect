import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../repositories/chat_repository.dart';

class DeleteMessageParams {
  final String roomId;
  final String messageId;

  DeleteMessageParams({
    required this.roomId,
    required this.messageId,
  });
}

@injectable
class DeleteMessageUseCase {
  final ChatRepository _chatRepository;

  DeleteMessageUseCase(this._chatRepository);

  Future<Either<Failure, void>> call(DeleteMessageParams params) async {
    try {
      await _chatRepository.deleteMessage(
        params.roomId,
        params.messageId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete message: $e'));
    }
  }
}