import '../../../data/models/chat_message_model.dart';
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class SendMessageParams {
  final String roomId;
  final String content;
  final int userId;
  final String username;
  final DateTime sentAt;

  SendMessageParams({
    required this.roomId,
    required this.content,
    required this.userId,
    required this.username,
    required this.sentAt,
  });
}

@injectable
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call(SendMessageParams params) async {
    print('🚀 [SendMessageUseCase] Starting send message process');
    print('📋 [SendMessageUseCase] Params - roomId: ${params.roomId}, userId: ${params.userId}, username: ${params.username}');
    print('💬 [SendMessageUseCase] Message content: "${params.content}"');
    print('⏰ [SendMessageUseCase] Sent at: ${params.sentAt}');
    
    try {
      print('📡 [SendMessageUseCase] Calling repository.sendMessageViaWebSocket...');
      await repository.sendMessageViaWebSocket(params.roomId, params.content);
      print('✅ [SendMessageUseCase] Message sent successfully via WebSocket');
      return const Right(null);
    } on ServerFailure catch (failure) {
      print('❌ [SendMessageUseCase] ServerFailure caught: ${failure.message}');
      return Left(failure);
    } catch (e) {
      print('💥 [SendMessageUseCase] Unexpected error caught: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}