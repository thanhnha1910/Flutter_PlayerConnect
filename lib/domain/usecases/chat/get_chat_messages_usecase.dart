import '../../../data/models/chat_message_model.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class GetChatMessagesParams {
  final String roomId;
  final int page;
  final int size;

  GetChatMessagesParams({
    required this.roomId,
    this.page = 0,
    this.size = 20,
  });
}

@injectable
class GetChatMessagesUseCase {
  final ChatRepository repository;

  GetChatMessagesUseCase(this.repository);

  Future<Either<Failure, List<ChatMessageModel>>> call(GetChatMessagesParams params) async {
    try {
      final result = await repository.getChatMessages(
        params.roomId,
        page: params.page,
        size: params.size,
      );
      return Right(result);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}