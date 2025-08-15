import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/chatbot_models.dart';

abstract class ChatbotRepository {
  Future<Either<Failure, ChatbotResponseDTO>> sendMessage(
    ChatbotRequestDTO request
  );
  Future<Either<Failure, bool>> checkHealth();
}