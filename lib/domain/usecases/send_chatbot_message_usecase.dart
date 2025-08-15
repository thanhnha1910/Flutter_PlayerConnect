import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../repositories/chatbot_repository.dart';
import '../../data/models/chatbot_models.dart';

@injectable
class SendChatbotMessageUseCase {
  final ChatbotRepository _repository;

  SendChatbotMessageUseCase(this._repository);

  Future<Either<Failure, ChatbotResponseDTO>> call(
    SendChatbotMessageParams params
  ) async {
    final request = ChatbotRequestDTO(
      message: params.message,
      sessionId: params.sessionId,
      context: params.context,
    );
    
    return await _repository.sendMessage(request);
  }
}

class SendChatbotMessageParams {
  final String message;
  final String? sessionId;
  final Map<String, dynamic>? context;

  SendChatbotMessageParams({
    required this.message,
    this.sessionId,
    this.context,
  });
}